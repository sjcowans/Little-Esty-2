require 'csv'

namespace :import do
  task :all => :environment do
    Rake::Task['import:customers'].invoke
    Rake::Task['import:merchants'].invoke
    Rake::Task['import:items'].invoke
    Rake::Task['import:invoices'].invoke
    Rake::Task['import:transactions'].invoke
    Rake::Task['import:invoice_items'].invoke
  end

  task :customers => :environment do
    import_csv('db/data/customers.csv', Customer, 'log/customers_import.log')
  end

  task :merchants => :environment do
    import_csv('db/data/merchants.csv', Merchant, 'log/merchants_import.log')
  end

  task :items => :environment do
    import_csv('db/data/items.csv', Item, 'log/items_import.log')
  end

  task :invoices => :environment do
    import_csv('db/data/invoices.csv', Invoice, 'log/invoices_import.log') do |row|
      {
        id: row['id'],
        customer_id: row['customer_id'],
        status: map_status(row['status']),
        created_at: row['created_at'],
        updated_at: row['updated_at']
      }
    end
  end

  task :transactions => :environment do
    import_csv('db/data/transactions.csv', Transaction, 'log/transactions_import.log') do |row|
      {
        id: row['id'],
        invoice_id: row['invoice_id'],
        credit_card_number: row['credit_card_number'],
        credit_card_expiration_date: parse_date(row['credit_card_expiration_date']),
        result: map_status(row['result']),
        created_at: row['created_at'],
        updated_at: row['updated_at']
      }
    end
  end

  task :invoice_items => :environment do
    import_csv('db/data/invoice_items.csv', InvoiceItem, 'log/invoice_items_import.log') do |row|
      {
        id: row['id'],
        item_id: row['item_id'],
        invoice_id: row['invoice_id'],
        quantity: row['quantity'],
        unit_price: row['unit_price'],
        status: map_status(row['status']),
        created_at: row['created_at'],
        updated_at: row['updated_at']
      }
    end
  end
end

def import_csv(file_path, model, log_file_path)
  File.open(log_file_path, 'w') do |log_file|
    invalid_count = 0
    duplicate_count = 0
    success_count = 0
    total_count = 0

    CSV.foreach(file_path, headers: true) do |row|
      total_count += 1
      attributes = block_given? ? yield(row) : row.to_hash

      begin
        record = model.find_or_initialize_by(id: attributes['id'])
        attributes.except!('id') # Avoid reassigning the primary key
        record.assign_attributes(attributes)

        if record.save
          success_count += 1
          log_file.puts "SUCCESS: #{model.name} record ID #{attributes['id']} imported successfully."
        else
          invalid_count += 1
          log_file.puts "INVALID: #{model.name} record ID #{attributes['id']} failed to import. Errors: #{record.errors.full_messages.join(', ')}"
        end
      rescue ActiveRecord::RecordNotUnique
        duplicate_count += 1
        log_file.puts "DUPLICATE: #{model.name} record ID #{attributes['id']} already exists. Skipping."
      end
    end

    ActiveRecord::Base.connection.reset_pk_sequence!(model.table_name)
    log_file.puts "\nSUMMARY for #{model.name.pluralize}:"
    log_file.puts "Total Records Processed: #{total_count}"
    log_file.puts "Successfully Imported: #{success_count}"
    log_file.puts "Invalid Records: #{invalid_count}"
    log_file.puts "Duplicate Records: #{duplicate_count}"
  end

  puts "#{model.name.pluralize} import completed. Check the log file at #{log_file_path} for details."
end

def map_status(status)
  case status
  when 'cancelled', 'failed', 'pending' then 3
  when 'in progress', 'packaged' then 2
  when 'completed', 'success', 'shipped' then 1
  else status
  end
end

def parse_date(date_string)
  return nil if date_string.blank?

  begin
    Date.parse(date_string)
  rescue ArgumentError
    puts "Invalid date format: #{date_string}. Returning nil."
    nil
  end
end
