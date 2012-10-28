require 'active_record/fixtures'

def log_progress(msg)
  print msg
  STDOUT.flush
end

def load_yaml(filename, fail_on_missing = true)
  full_path = File.join(File.dirname(__FILE__), filename)
  if File.exists?(full_path)
    YAML::load_file(full_path)
  else
    raise "Expected '#{filename}' configuration file does not exist!" if fail_on_missing
    Hash.new
  end
end


namespace :db do
  desc 'loads fixtures'
  task :load_fixtures => :environment do
    puts
    puts '== Loading fixtures:'
    Dir.glob(RAILS_ROOT + '/db/fixtures/*.yml').each do |file|
      base_name = File.basename(file, '.*')
      print "#{base_name}..."
      Fixtures.create_fixtures('db/fixtures', base_name)
      puts 'OK'
    end
  end

  desc 'Create YAML test fixtures from data in an existing database.
        Defaults to development database. Set RAILS_ENV to override.'
  namespace :fixtures do
    task :dump => :environment do
      dump_dir = ENV['DIR'] || File.join(RAILS_ROOT, 'db', 'fixtures')
      sql = 'SELECT * FROM %s'
      skip_tables = ['schema_info', 'schema_migrations' 'sessions']
      ActiveRecord::Base.establish_connection
      tables = (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables) - skip_tables
      tables.each do |table_name|
        i = '00000'
        filename = File.join(dump_dir, "#{table_name}.yml")
        if File.exists?(filename) and not ENV['EXISTING'] == 'overwrite'
          if ENV['EXISTING'] == 'skip'
            overwrite = false
          else
            print "File #{filename} already exists. Overwrite? [yNa]: "
            ans = $stdin.gets.downcase
            if ans.starts_with?('y')
              overwrite = 'w'
            elsif ans.starts_with?('a')
              overwrite = 'a'
            end
          end
        else
          overwrite = 'w'
        end

        if overwrite
          puts "dumping table #{table_name}..."
          File.open(filename, overwrite) do |file|
            data = ActiveRecord::Base.connection.select_all(sql % table_name)
            file.write data.inject({}) {|hash, record|
              hash["#{table_name}_#{i.succ!}"] = record
              hash
            }.to_yaml
          end
        else
          puts "skipping table #{table_name}."
        end
      end
    end
  end

  namespace :migrations do
    desc 'run data migrations for release 0.3'
    task :release_3 => :environment do
      company = Company.find_or_create_by_name 'test company'
      section = CompanySection.find_or_create_by_name 'test section'
      wvk = User.find_or_initialize_by_login 'wvk'
#       wvk.update_attributes :forename => 'Willem', :surname => 'van Kerkhof'
#       company.main_section = section
#       company.admin = wvk
#       company.save!
#       User.all.each do |user|
#         user.company_section = section
#         user.password = 'test'
#         user.password_confirmation = 'test'
#         user.save!
#       end
#       tweber = User.find_by_login 't-weber'
#       Client.all.each do |client|
#         client.contact_person = tweber
#         client.company = company
#         client.save!
#       end
#       Device.all.each do |device|
#         product = Product.find_or_initialize_by_code device.code
#         product.article = device
#         product.company_section = section
#         product.category_ids = device.category_ids
#         product.save!
#       end
#       Category.all.each do |category|
#         category.company_section = section
#         category.save
#       end
#       Rental.all.each do |rental|
#         rental.sender = section
#         rental.save!
#       end
      RentalPeriod.all.each do |period|
        period.product    = Product.first :conditions => {:article_id => period.device_id, :article_type => 'Device'}
        period.price      = period.read_attribute(:price) * period.rental.billed_duration
        period.unit_price = period.price / period.count
        period.save
      end
    end

    desc 'run data migrations for release 0.4.1'
    task :release_4_1 => :environment do
#       User.all.each do |user|
#         user.address ||= Address.new
#         user.address.street     ||= user.read_attribute(:street)
#         user.address.postalcode ||= user.read_attribute(:postalcode)
#         user.address.locality   ||= user.read_attribute(:locality)
#         user.address.country    ||= user.read_attribute(:country)
#         user.address.phone      ||= user.read_attribute(:phone)
#         user.address.fax        ||= user.read_attribute(:fax)
#         user.address.mobile     ||= user.read_attribute(:mobile)
#         user.address.save!
#       end
#       CompanySection.all.each do |company_section|
#         company_section.bank_account ||= BankAccount.new
#         company_section.bank_account.number         ||= company_section.read_attribute(:bank_account)
#         company_section.bank_account.bank_name      ||= company_section.read_attribute(:bank_name)
#         company_section.bank_account.registrar_name ||= company_section.read_attribute(:bank_account_owner)
#         company_section.bank_account.blz            ||= company_section.read_attribute(:bank_blz)
#         company_section.bank_account.iban           ||= company_section.read_attribute(:bank_iban)
#         company_section.bank_account.bic            ||= company_section.read_attribute(:bank_bic)
#         company_section.save!
#       end
      RentalPeriod.all.each do |rp|
        if rp.product and rp.product.service?
          si = ServiceItem.new
          attrs = rp.attributes
          process_id = attrs.delete 'rental_id'
          si.attributes = attrs
          si.process_id = process_id
          si.process_id = 'Rental'
          si.duration = 1
          si.save
        end
      end
    end

  end

  task :materialize_views => :environment do
    DeviceAvailability.transaction do
      DeviceAvailability.connection.execute "truncate table device_availabilities_table"
      DeviceAvailability.connection.execute "insert into device_availabilities_table select * from device_availabilities"
    end
  end
end


