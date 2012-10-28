module DeviceCsvImporter
  HEADER_MAPPING = {
    'Lagercode'     => :code,
#     'Hersteller'    => :make,
    'Bezeichnung'   => :name,
#     'VK Brutto'     => :,
#     'VK Netto'      => :,
    'Gewicht'       => :weight,
#     'Einheit'       => :,
#     'EK Netto'      => :,
    'Lagerbestand'  => :available_count,
#     'Besitzer'      => :owner_name
  }

  def self.import!(csv_file)
    rows       = FasterCSV.read(csv_file, :col_sep => ';')
    fieldorder = rows.shift
    attribute_mapping = fieldorder.map {|name| HEADER_MAPPING[name] }
    rows.each do |row|
      code   = row[attribute_mapping.index(:code)]
      device = Device.find_or_initialize_by_code code
      attribute_mapping.each_with_index do |attribute, index|
        device.send "#{attribute}=", row[index] unless attribute.nil?
      end
      result = device.save
      yield result if block_given?
    end
  end
end
