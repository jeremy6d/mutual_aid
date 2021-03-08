class NormalizeFulfillmentPublicIds < ActiveRecord::Migration[6.0]
  def change
    Fulfillment.where.not(public_id: nil).each do |f|
      old_pid = f.public_id
      new_pid = f.public_id.gsub('#', '')
      f.public_id = new_pid
      f.save touch:false
      puts "Converted #{old_pid} to #{new_pid}"
    end
    Fulfillment.where(public_id: nil).each do |f|
      puts "setting fulfillment with no public id to #{f.set_public_id}"
      f.save touch:false
    end
    AidRequest.in_progress.each &:check_deliveries!
  end
end
