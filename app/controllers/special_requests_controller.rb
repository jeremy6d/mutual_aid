class SpecialRequestsController < ApplicationController
  def index
    @requests = AidRequest.special_requests.outstanding.prioritized
    @item_map = @requests.each_with_object({}) do |r, out| 
      r.special_requests.
        split(",").
        each do |item|
          item = item.downcase.strip
          out[item] ||= []
          out[item] << r
        end
    end
  end
end
