class FulfillmentsController < AuthorizedOnlyController
  before_action :set_fulfillment, only: %i(show edit update destroy mutate)
  respond_to :html, :json

  # GET /fulfillments
  # GET /fulfillments.json
  def index
    @fulfillments = aid_request.fulfillments
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

  def mutate
    use_logidze_responsible do
      unless params[:message].blank?
        @fulfillment.notes.create body: params[:message], author: current_volunteer
      end 
      @fulfillment.deliver! if params.key? :delivered
      @fulfillment.return! if params.key? :returned
      @fulfillment.cancel! if params.key? :cancelled
    end

    respond_to do |format| 
      format.json { render :show, status: :ok, location: [@aid_request, @fulfillment] }
      format.html { redirect_to [@aid_request, @fulfillment], notice: "Fulfillment has been #{@fulfillment.status}." }
    end 
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
    end

    def set_fulfillment
      @fulfillment = aid_request.fulfillments.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fulfillment_params
      params.require(:fulfillment).permit(:packing_notes, 
                                          :contents, 
                                          :contents_sheet_image, 
                                          :num_bags)
    end
end
