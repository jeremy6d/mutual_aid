class FulfillmentsController < AuthorizedOnlyController
  before_action :set_fulfillment, only: %i(show edit update destroy cancel)
  respond_to :html, :json

  # GET /fulfillments
  def index
    if params[:search_by]
      terms = params[:search_by].gsub(/[\-\.\(\)]*/, "")
      ids = Fulfillment.basic_search(terms).map(&:id)
      requests = Fulfillment.include(:aid_requests).where(id: ids)
      @count = ids.size
    else
      @fulfillments = case params[:status]
      when "", nil, "all"
        Fulfillment.order(created_at: :desc)
      else
        Fulfillment.where(status: params[:status]).
                    order(updated_at: :desc)
      end
    end
    @fulfillments = @fulfillments.page params[:page]
    respond_to do |format|
      format.html
      format.csv { send_data @fulfillments.to_csv, filename: "aid_requests-#{Date.today}.csv" }
    end
  end

  # GET /fulfillments/1
  # GET /fulfillments/1.json
  def show
  end

  # GET /fulfillments/new
  def new
    @fulfillment = aid_request.fulfillments.build
  end

  # GET /fulfillments/1/edit
  def edit
  end

  # POST /fulfillments
  # POST /fulfillments.json
  def create
    @fulfillment = aid_request.fulfillments.build(fulfillment_params)
    @fulfillment.fulfiller = current_volunteer
    respond_to do |format|
      if @fulfillment.save
        format.html { redirect_to @aid_request, notice: 'Fulfillment was successfully created.' }
        format.json { render :show, status: :created, location: @fulfillment }
      else
        format.html { render :new }
        format.json { render json: @fulfillment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fulfillments/1
  # PATCH/PUT /fulfillments/1.json
  def update
    respond_to do |format|
      if @fulfillment.update(fulfillment_params)
        format.html { redirect_to @aid_request, notice: 'Fulfillment was successfully updated.' }
        format.json { render :show, status: :ok, location: @fulfillment }
      else
        format.html { render :edit }
        format.json { render json: @fulfillment.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel
    @fulfillment.cancel!
    redirect_to @aid_request, notice: 'Fulfillment was cancelled.'
  end

  # DELETE /fulfillments/1
  # DELETE /fulfillments/1.json
  def destroy
    @fulfillment.destroy
    respond_to do |format|
      format.html { redirect_to fulfillments_url, notice: 'Fulfillment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def aid_request
      @aid_request ||= AidRequest.find(params[:aid_request_id])
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def fulfillments_set
      if aid_request&.persisted?
        aid_request.fulfillments
      else
        Fulfillment
      end
    end

    def set_fulfillment
      @fulfillment = fulfillments_set.find(params[:id])
      @aid_request = @fulfillment.aid_request
    end

    # Only allow a list of trusted parameters through.
    def fulfillment_params
      params.require(:fulfillment).permit(:special, 
                                          :contents)
    end
end
