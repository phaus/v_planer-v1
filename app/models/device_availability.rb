class DeviceAvailability < ActiveRecord::Base

  set_table_name 'device_availabilities_table'

  belongs_to :device

  scope :between, lambda {|from_date, to_date|
    where ['value between ? and ?', from_date, to_date]
  }

  def date
    self.value
  end

end

# CREATE VIEW `device_availabilities` AS select `calendar_dates`.`value` AS `value`,`product_stock_entries`.`device_id` AS `device_id`,count(distinct `unavailabilities`.`id`) AS `count` from (`calendar_dates` join (`unavailabilities` join `product_stock_entries` on((`product_stock_entries`.`id` = `unavailabilities`.`product_stock_entry_id`))) on((`calendar_dates`.`value` between `unavailabilities`.`from_date` and `unavailabilities`.`to_date`))) group by `calendar_dates`.`id`,`product_stock_entries`.`device_id`;

