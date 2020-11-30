module AidRequestsHelper
  def header_class_for(obj)
    if obj.urgent? && !obj.terminal?
      'bg-danger text-white'
    elsif obj.call_back?
      'bg-success text-white'
    elsif obj.in_progress? 
       'bg-warning text-dark'
    elsif obj.fresh?
      'bg-info text-dark'
    else  
      'bg-light text-black'
    end
  end

  def status_filter
    params.fetch(:status, "all")
  end
end
