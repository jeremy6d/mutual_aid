class DeliveriesController < AuthorizedOnlyController
  before_action :set_delivery, only: [:show, :edit, :update, :destroy]

  # GET /deliveries
  # GET /deliveries.json
  def index
    @deliveries = Delivery.all
  end

  def mine
    @in_progress_deliveries = current_volunteer.deliveries.on_the_way
    @past_deliveries = current_volunteer.deliveries.delivered
  end

  # GET /deliveries/1
  # GET /deliveries/1.json
  def show
  end

  # GET /deliveries/new
  def new
    @fulfillments = Fulfillment.packed.order(created_at: :asc)
    @delivery = Delivery.new
    @delivery.notes.build
  end

  # GET /deliveries/1/edit
  def edit
    @fulfillments = Fulfillment.packed.order(created_at: :asc)
    @delivery.notes.build
  end

  # POST /deliveries
  # POST /deliveries.json
  def create
    @delivery = Delivery.new(delivery_params)
    @delivery.driver = current_volunteer
    respond_to do |format|
      if @delivery.save
        format.html { redirect_to @delivery, notice: 'Delivery was successfully created.' }
        format.json { render :show, status: :created, location: @delivery }
      else
            @fulfillments = Fulfillment.packed.order(created_at: :asc)
        format.html { render :new }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deliveries/1
  # PATCH/PUT /deliveries/1.json
  def update
    respond_to do |format|
      if @delivery.update(delivery_params)
        format.html { redirect_to @delivery, notice: 'Delivery was successfully updated.' }
        format.json { render :show, status: :ok, location: @delivery }
      else
            @fulfillments = Fulfillment.packed.order(created_at: :asc)
    # @delivery.notes.build
        format.html { render :edit }
        format.json { render json: @delivery.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deliveries/1
  # DELETE /deliveries/1.json
  def destroy
    @delivery.destroy
    respond_to do |format|
      format.html { redirect_to deliveries_url, notice: 'Delivery was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_delivery
      @delivery = Delivery.find(params[:id])
    end

    def delivery
      @delivery || set_delivery
    end

    # Only allow a list of trusted parameters through.
    def delivery_params
      params.require(:delivery).
             permit(notes_attributes: [ :body ], fulfillment_ids: []).
             tap do |dp|
        ids = dp[:fulfillment_ids] + @delivery.try(:fulfillment_ids).to_a
        dp[:fulfillment_ids] = ids.uniq.reject(&:blank?)
        dp[:notes_attributes].each { |n, attrs| attrs[:author] = current_volunteer }
        dp
      end
    end
end
