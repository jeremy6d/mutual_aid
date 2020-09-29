class PackingSlipsController < AuthorizedOnlyController
  def index
    @packing_slips = PackingSlip.order(created_at: :desc)
    @packing_slips = if params[:archive]
      @packing_slips.where('updated_at <= ?', 1.week.ago)
    else
      @packing_slips.where('updated_at > ?', 1.week.ago)
    end
  end

  def new
    @fulfillments = Fulfillment.includes(:aid_request).
                                pending.
                                order('aid_requests.neighborhood desc, fulfillments.created_at asc')
    @packing_slip = PackingSlip.new
  end

  def create
    @packing_slip = PackingSlip.new packing_slip_params
    if @packing_slip.save
      redirect_to @packing_slip, notice: "Packing slip created."
    else
      render :new
    end
  end
  
  def show
    @packing_slip = PackingSlip.find params[:id]
  end

  def print
    @fulfillments = Fulfillment.includes(:aid_request).
                                where(packing_slip_id: params[:id]).
                                order('aid_requests.neighborhood desc, fulfillments.created_at asc')
    render :print, layout: false
  end

private
  def packing_slip_params
    params.require(:packing_slip).
           permit(:remarks, fulfillment_ids: []).
           merge(creator: current_volunteer)
  end
end
