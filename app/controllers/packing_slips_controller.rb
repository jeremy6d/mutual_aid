class PackingSlipsController < AuthorizedOnlyController
  def index
    @packing_slips = PackingSlip.order(created_at: :desc)
  end

  def new
    @fulfillments = Fulfillment.pending
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
    @fulfillments = Fulfillment.where(packing_slip_id: params[:id])
    render :print, layout: false
  end

private
  def packing_slip_params
    params.require(:packing_slip).
           permit(:remarks, fulfillment_ids: []).
           merge(creator: current_volunteer)
  end
end
