json.extract! fulfillment, :id, :status
json.url aid_request_fulfillment_url(fulfillment.aid_request, fulfillment, format: :json)
