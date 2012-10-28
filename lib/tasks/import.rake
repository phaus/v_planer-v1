namespace :import do

  namespace :devices do
    task :csv => :environment do
      DeviceCsvImporter.import!('db/JTL-Export-Artikeldaten-06122009.csv') do |ok|
        putc ok ? '.' : 'E'
        $stdout.flush
      end
      puts 'done'
    end
  end

  namespace :clients do
    task :csv => :environment do
      ClientCsvImporter.import!('db/JTL-Export-Kundendaten-06122009.csv') do |ok|
        putc ok ? '.' : 'E'
        $stdout.flush
      end
      puts 'done'
    end
  end

end

