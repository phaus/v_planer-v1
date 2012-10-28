module ClientCsvImporter
  HEADER_MAPPING = {
    'Kundennummer'   => :client_no,
    'Firma'          => :company,
# #     'Zu Händen'      => :,
    'Anrede'         => :title,
    'Vorname'        => :forename,
    'Nachname'       => :surname,
    'Strasse'        => :street,
    'PLZ'            => :postalcode,
    'Ort'            => :locality,
    'Tel'            => :phone,
#     'Fax'            => :fax,
#     'Mobil'          => :mobile,
    'E-Mail'         => :email,
#     'Homepage (WWW)' => :homepage,
# #     'Zahlungsziel'   => :,
#     'Rabatt'         => :discount
  }

  def self.import!(csv_file)
    rows       = FasterCSV.read(csv_file, :col_sep => ';')
    fieldorder = rows.shift
    attribute_mapping = fieldorder.map {|name| HEADER_MAPPING[name] }
    rows.each do |row|
      client_id = row[attribute_mapping.index(:client_no)]
      client = Client.find_or_initialize_by_client_no client_id
      attribute_mapping.each_with_index do |attribute, index|
        client.send "#{attribute}=", row[index] unless attribute.nil?
      end
      result = client.save
      yield result if block_given?
    end
  end
end
