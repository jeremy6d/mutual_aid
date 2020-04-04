class FulfillmentsController < ApplicationController
  before_action :authenticate_volunteer!
  before_action :set_fulfillment, only: [:show, :edit, :update, :destroy, :delivered]

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

  def delivered
    @fulfillment.deliver!
    head :no_content
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
      params.require(:fulfillment).permit(:notes, :contents, :contents_sheet_image, :num_bags)
    end
end
