namespace :purge do
  task :incomplete_records => :environment do
    models = [Customer, Merchant, Item, Invoice, Transaction, InvoiceItem]
    total_purged = 0

    models.each do |model|
      purged_count = purge_invalid_records(model)
      total_purged += purged_count
      puts "#{purged_count} incomplete #{model.name.pluralize} records removed."
    end

    puts "Total incomplete records removed: #{total_purged}"
  end
end

def purge_invalid_records(model)
  invalid_records = model.all.reject(&:valid?)
  invalid_records.each(&:destroy)
  invalid_records.count
end
