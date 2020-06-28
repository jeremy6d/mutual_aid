class DeliveryFulfillmentsController < AuthorizedOnlyController
  def update
    @delivery = Delivery.find params[:id]
    @fulfillments = Fulfillment.find params[:fulfillment_ids]
    use_logidze_responsible do
      if params.key? :delivered
        @fulfillments.each &:deliver!
      elsif params.key? :cancelled
        @fulfillments.each &:cancel!
      else
        head(:bad_request) and return if params[:message].blank?
        @fulfillments.each(&:return!)  if params.key? :returned
      end
      if params[:message].present?
        message = params[:message] + "\n\nFulfillments: #{@fulfillments.map(&:public_id).join(', ')}"
        @delivery.notes.create body: message, author: current_volunteer # add contact one day
      end
    end
    render json: { status: @fulfillments.first.status }, status: :ok
  end
end
