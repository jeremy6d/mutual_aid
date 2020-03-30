class AidRequestsController < ApplicationController
  before_action :set_aid_request, only: [:show, :edit, :update, :destroy]

  # GET /aid_requests
  # GET /aid_requests.json
  def index
    @aid_requests = AidRequest.all
  end

  # GET /aid_requests/1
  # GET /aid_requests/1.json
  def show
  end

  # GET /aid_requests/new
  def new
    @aid_request = AidRequest.new
  end

  # GET /aid_requests/1/edit
  def edit
  end

  # POST /aid_requests
  # POST /aid_requests.json
  def create
    @aid_request = AidRequest.new(aid_request_params)

    respond_to do |format|
      if @aid_request.save
        format.html { redirect_to @aid_request, notice: 'Aid request was successfully created.' }
        format.json { render :show, status: :created, location: @aid_request }
      else
        format.html { render :new }
        format.json { render json: @aid_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /aid_requests/1
  # PATCH/PUT /aid_requests/1.json
  def update
    respond_to do |format|
      if @aid_request.update(aid_request_params)
        format.html { redirect_to @aid_request, notice: 'Aid request was successfully updated.' }
        format.json { render :show, status: :ok, location: @aid_request }
      else
        format.html { render :edit }
        format.json { render json: @aid_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /aid_requests/1
  # DELETE /aid_requests/1.json
  def destroy
    @aid_request.destroy
    respond_to do |format|
      format.html { redirect_to aid_requests_url, notice: 'Aid request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_aid_request
      @aid_request = AidRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def aid_request_params
      params.require(:aid_request).permit(:volunteer_name, :caller_first_name, :caller_last_name, :caller_phone_number, :caller_address, :supplies_needed, :persons, :notes, :status, indications: [])
    end
end
