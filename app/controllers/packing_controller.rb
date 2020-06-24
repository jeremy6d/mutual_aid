class PackingController < ApplicationController
  def index
    @fulfillments = incoming_fulfillments
  end

  def pack
    @packing_slip = PackingSlip.new(packing_slip_params)
    if @packing_slip.save

  end

private
  def pending_fulfillments
    Fulfillment.pending
  end

  def incoming_ids
    @incoming_ids ||= params[:fulfillments].reject(&:blank?)
  end

  def fulfillments_to_pack
    pending_fulfillments.find incoming_ids
  end

  def packing_slip_params
    params.require(:packing_slip).
           permit(:packing_note, fulfillment_ids: []).
           merge(creator: current_volunteer)
  end
end
