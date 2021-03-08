SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: logidze_compact_history(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_compact_history(log_data jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
        DECLARE
          merged jsonb;
        BEGIN
          merged := jsonb_build_object(
            'ts',
            log_data#>'{h,1,ts}',
            'v',
            log_data#>'{h,1,v}',
            'c',
            (log_data#>'{h,0,c}') || (log_data#>'{h,1,c}')
          );

          IF (log_data#>'{h,1}' ? 'm') THEN
            merged := jsonb_set(merged, ARRAY['m'], log_data#>'{h,1,m}');
          END IF;

          return jsonb_set(
            log_data,
            '{h}',
            jsonb_set(
              log_data->'h',
              '{1}',
              merged
            ) - 0
          );
        END;
      $$;


--
-- Name: logidze_exclude_keys(jsonb, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_exclude_keys(obj jsonb, VARIADIC keys text[]) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
        DECLARE
          res jsonb;
          key text;
        BEGIN
          res := obj;
          FOREACH key IN ARRAY keys
          LOOP
            res := res - key;
          END LOOP;
          RETURN res;
        END;
      $$;


--
-- Name: logidze_logger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_logger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        DECLARE
          changes jsonb;
          version jsonb;
          snapshot jsonb;
          new_v integer;
          size integer;
          history_limit integer;
          debounce_time integer;
          current_version integer;
          merged jsonb;
          iterator integer;
          item record;
          columns_blacklist text[];
          ts timestamp with time zone;
          ts_column text;
        BEGIN
          ts_column := NULLIF(TG_ARGV[1], 'null');
          columns_blacklist := COALESCE(NULLIF(TG_ARGV[2], 'null'), '{}');

          IF TG_OP = 'INSERT' THEN
            snapshot = logidze_snapshot(to_jsonb(NEW.*), ts_column, columns_blacklist);

            IF snapshot#>>'{h, -1, c}' != '{}' THEN
              NEW.log_data := snapshot;
            END IF;

          ELSIF TG_OP = 'UPDATE' THEN

            IF OLD.log_data is NULL OR OLD.log_data = '{}'::jsonb THEN
              snapshot = logidze_snapshot(to_jsonb(NEW.*), ts_column, columns_blacklist);
              IF snapshot#>>'{h, -1, c}' != '{}' THEN
                NEW.log_data := snapshot;
              END IF;
              RETURN NEW;
            END IF;

            history_limit := NULLIF(TG_ARGV[0], 'null');
            debounce_time := NULLIF(TG_ARGV[3], 'null');

            current_version := (NEW.log_data->>'v')::int;

            IF ts_column IS NULL THEN
              ts := statement_timestamp();
            ELSE
              ts := (to_jsonb(NEW.*)->>ts_column)::timestamp with time zone;
              IF ts IS NULL OR ts = (to_jsonb(OLD.*)->>ts_column)::timestamp with time zone THEN
                ts := statement_timestamp();
              END IF;
            END IF;

            IF NEW = OLD THEN
              RETURN NEW;
            END IF;

            IF current_version < (NEW.log_data#>>'{h,-1,v}')::int THEN
              iterator := 0;
              FOR item in SELECT * FROM jsonb_array_elements(NEW.log_data->'h')
              LOOP
                IF (item.value->>'v')::int > current_version THEN
                  NEW.log_data := jsonb_set(
                    NEW.log_data,
                    '{h}',
                    (NEW.log_data->'h') - iterator
                  );
                END IF;
                iterator := iterator + 1;
              END LOOP;
            END IF;

            changes := hstore_to_jsonb_loose(
              hstore(NEW.*) - hstore(OLD.*)
            );

            new_v := (NEW.log_data#>>'{h,-1,v}')::int + 1;

            size := jsonb_array_length(NEW.log_data->'h');
            version := logidze_version(new_v, changes, ts, columns_blacklist);

            IF version->>'c' = '{}' THEN
              RETURN NEW;
            END IF;

            IF (
              debounce_time IS NOT NULL AND
              (version->>'ts')::bigint - (NEW.log_data#>'{h,-1,ts}')::text::bigint <= debounce_time
            ) THEN
              -- merge new version with the previous one
              new_v := (NEW.log_data#>>'{h,-1,v}')::int;
              version := logidze_version(new_v, (NEW.log_data#>'{h,-1,c}')::jsonb || changes, ts, columns_blacklist);
              -- remove the previous version from log
              NEW.log_data := jsonb_set(
                NEW.log_data,
                '{h}',
                (NEW.log_data->'h') - (size - 1)
              );
            END IF;

            NEW.log_data := jsonb_set(
              NEW.log_data,
              ARRAY['h', size::text],
              version,
              true
            );

            NEW.log_data := jsonb_set(
              NEW.log_data,
              '{v}',
              to_jsonb(new_v)
            );

            IF history_limit IS NOT NULL AND history_limit = size THEN
              NEW.log_data := logidze_compact_history(NEW.log_data);
            END IF;
          END IF;

          return NEW;
        END;
        $$;


--
-- Name: logidze_snapshot(jsonb, text, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_snapshot(item jsonb, ts_column text, blacklist text[] DEFAULT '{}'::text[]) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
        DECLARE
          ts timestamp with time zone;
        BEGIN
          IF ts_column IS NULL THEN
            ts := statement_timestamp();
          ELSE
            ts := coalesce((item->>ts_column)::timestamp with time zone, statement_timestamp());
          END IF;
          return json_build_object(
            'v', 1,
            'h', jsonb_build_array(
                   logidze_version(1, item, ts, blacklist)
                 )
            );
        END;
      $$;


--
-- Name: logidze_version(bigint, jsonb, timestamp with time zone, text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_version(v bigint, data jsonb, ts timestamp with time zone, blacklist text[] DEFAULT '{}'::text[]) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
        DECLARE
          buf jsonb;
        BEGIN
          buf := jsonb_build_object(
                   'ts',
                   (extract(epoch from ts) * 1000)::bigint,
                   'v',
                    v,
                    'c',
                    logidze_exclude_keys(data, VARIADIC array_append(blacklist, 'log_data'))
                   );
          IF coalesce(current_setting('logidze.meta', true), '') <> '' THEN
            buf := jsonb_set(buf, ARRAY['m'], current_setting('logidze.meta')::jsonb);
          END IF;
          RETURN buf;
        END;
      $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: aid_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aid_requests (
    id bigint NOT NULL,
    caller_first_name character varying,
    caller_last_name character varying,
    caller_phone_number character varying,
    status character varying,
    caller_address text,
    supplies_needed text,
    persons text,
    notes text,
    indications character varying[] DEFAULT '{}'::character varying[],
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    original_taker_id bigint,
    log_data jsonb,
    urgent boolean DEFAULT false,
    neighborhood character varying,
    special_requests text
);


--
-- Name: aid_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aid_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aid_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aid_requests_id_seq OWNED BY public.aid_requests.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: deliveries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deliveries (
    id bigint NOT NULL,
    notes character varying,
    driver_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    status character varying
);


--
-- Name: deliveries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.deliveries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deliveries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.deliveries_id_seq OWNED BY public.deliveries.id;


--
-- Name: fulfillments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fulfillments (
    id bigint NOT NULL,
    fulfiller_id bigint,
    aid_request_id bigint,
    contents text,
    status character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    delivery_id bigint,
    packing_slip_id bigint,
    special boolean DEFAULT false,
    public_id character varying
);


--
-- Name: fulfillments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fulfillments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fulfillments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fulfillments_id_seq OWNED BY public.fulfillments.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    noteable_id bigint,
    noteable_type character varying,
    author_id bigint,
    body text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: packing_slips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.packing_slips (
    id bigint NOT NULL,
    creator_name character varying,
    creator_id bigint,
    remarks text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: packing_slips_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.packing_slips_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: packing_slips_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.packing_slips_id_seq OWNED BY public.packing_slips.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: volunteers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.volunteers (
    id bigint NOT NULL,
    first_name character varying,
    last_name character varying,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    approved_by_id bigint,
    phone_number character varying
);


--
-- Name: volunteers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.volunteers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: volunteers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.volunteers_id_seq OWNED BY public.volunteers.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: aid_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests ALTER COLUMN id SET DEFAULT nextval('public.aid_requests_id_seq'::regclass);


--
-- Name: deliveries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries ALTER COLUMN id SET DEFAULT nextval('public.deliveries_id_seq'::regclass);


--
-- Name: fulfillments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillments ALTER COLUMN id SET DEFAULT nextval('public.fulfillments_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: packing_slips id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packing_slips ALTER COLUMN id SET DEFAULT nextval('public.packing_slips_id_seq'::regclass);


--
-- Name: volunteers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteers ALTER COLUMN id SET DEFAULT nextval('public.volunteers_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: aid_requests aid_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT aid_requests_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: deliveries deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- Name: fulfillments fulfillments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillments
    ADD CONSTRAINT fulfillments_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: packing_slips packing_slips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packing_slips
    ADD CONSTRAINT packing_slips_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: volunteers volunteers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteers
    ADD CONSTRAINT volunteers_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_aid_requests_on_original_taker_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_aid_requests_on_original_taker_id ON public.aid_requests USING btree (original_taker_id);


--
-- Name: index_deliveries_on_driver_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deliveries_on_driver_id ON public.deliveries USING btree (driver_id);


--
-- Name: index_fulfillments_on_aid_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fulfillments_on_aid_request_id ON public.fulfillments USING btree (aid_request_id);


--
-- Name: index_fulfillments_on_delivery_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fulfillments_on_delivery_id ON public.fulfillments USING btree (delivery_id);


--
-- Name: index_fulfillments_on_fulfiller_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fulfillments_on_fulfiller_id ON public.fulfillments USING btree (fulfiller_id);


--
-- Name: index_fulfillments_on_packing_slip_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_fulfillments_on_packing_slip_id ON public.fulfillments USING btree (packing_slip_id);


--
-- Name: index_notes_on_author_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_author_id ON public.notes USING btree (author_id);


--
-- Name: index_notes_on_noteable_type_and_noteable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_noteable_type_and_noteable_id ON public.notes USING btree (noteable_type, noteable_id);


--
-- Name: index_packing_slips_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packing_slips_on_creator_id ON public.packing_slips USING btree (creator_id);


--
-- Name: index_volunteers_on_approved_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_volunteers_on_approved_by_id ON public.volunteers USING btree (approved_by_id);


--
-- Name: index_volunteers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_volunteers_on_email ON public.volunteers USING btree (email);


--
-- Name: index_volunteers_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_volunteers_on_reset_password_token ON public.volunteers USING btree (reset_password_token);


--
-- Name: aid_requests logidze_on_aid_requests; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER logidze_on_aid_requests BEFORE INSERT OR UPDATE ON public.aid_requests FOR EACH ROW WHEN ((COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text)) EXECUTE FUNCTION public.logidze_logger('null', 'updated_at');


--
-- Name: notes fk_rails_36c9deba43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_36c9deba43 FOREIGN KEY (author_id) REFERENCES public.volunteers(id);


--
-- Name: aid_requests fk_rails_4566916b7c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aid_requests
    ADD CONSTRAINT fk_rails_4566916b7c FOREIGN KEY (original_taker_id) REFERENCES public.volunteers(id);


--
-- Name: volunteers fk_rails_53111441b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.volunteers
    ADD CONSTRAINT fk_rails_53111441b8 FOREIGN KEY (approved_by_id) REFERENCES public.volunteers(id);


--
-- Name: packing_slips fk_rails_5faf5010f5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packing_slips
    ADD CONSTRAINT fk_rails_5faf5010f5 FOREIGN KEY (creator_id) REFERENCES public.volunteers(id);


--
-- Name: fulfillments fk_rails_62debf2cb1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fulfillments
    ADD CONSTRAINT fk_rails_62debf2cb1 FOREIGN KEY (fulfiller_id) REFERENCES public.volunteers(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: deliveries fk_rails_dbbcd08797; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT fk_rails_dbbcd08797 FOREIGN KEY (driver_id) REFERENCES public.volunteers(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20200328234323'),
('20200330215159'),
('20200331023643'),
('20200331023919'),
('20200331023920'),
('20200331144632'),
('20200331234514'),
('20200401205703'),
('20200401221719'),
('20200403171215'),
('20200403212439'),
('20200405172219'),
('20200406020029'),
('20200407052848'),
('20200408194004'),
('20200410160210'),
('20200616174851'),
('20200622205101'),
('20200624154700'),
('20210308151807');


