module FulfillmentsHelper
  def table_row_class_for(f)
    case f.status
    when "pending"
      "table-danger"
    when "packed"
      "table-info"
    when "on_the_way"
      "table-warning"
    when "delivered"
      "table-success"
    when "cancelled"
      "table-dark"
    end
  end
end
