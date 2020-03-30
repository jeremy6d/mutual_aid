json.extract! aid_request, :id, :volunteer_name, :caller_first_name, :caller_last_name, :caller_phone_number, :caller_address, :supplies_needed, :persons, :notes, :status, :created_at, :updated_at
json.url aid_request_url(aid_request, format: :json)
