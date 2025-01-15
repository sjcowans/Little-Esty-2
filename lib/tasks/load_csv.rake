require 'csv'
require 'fileutils'

namespace :import do
  task :all => :environment do
    %w[customers merchants items invoices transactions invoice_items].each do |entity|
      Rake::Task["import:#{entity}"].invoke
    end
  end

  %w[customers merchants items invoices transactions invoice_items].each do |entity|
    task entity.to_sym => :environment do
      import_csv(
        "db/data/#{entity}.csv",
        entity.classify.constantize,
        "log/#{entity}_import.log"
      )
    end
  end
end

def import_csv(file_path, model, log_file_path)
  FileUtils.mkdir_p(File.dirname(log_file_path))

  File.open(log_file_path, 'w') do |log_file|
    invalid_count = 0
    skipped_count = 0
    success_count = 0
    total_count = 0

    CSV.foreach(file_path, headers: true) do |row|
      total_count += 1
      attributes = transform_row(row, model)

      if attributes.nil?
        skipped_count += 1
        log_file.puts "SKIPPED: Invalid or incomplete data in row: #{row.to_h}"
        next
      end

      begin
        # Use find_or_create_by to prevent duplicates
        record = model.find_or_create_by(attributes.except(:id)) do |rec|
          rec.assign_attributes(attributes)
        end

        if record.persisted?
          success_count += 1
          log_file.puts "SUCCESS: #{model.name} record saved."
        else
          invalid_count += 1
          log_file.puts "INVALID: #{model.name} record failed: #{record.errors.full_messages.join(', ')}"
        end
      rescue ActiveRecord::RecordNotUnique
        skipped_count += 1
        log_file.puts "DUPLICATE: #{model.name} record already exists. Skipping."
      end
    end

    log_file.puts "\nSUMMARY for #{model.name.pluralize}:"
    log_file.puts "Total Records Processed: #{total_count}"
    log_file.puts "Successfully Imported: #{success_count}"
    log_file.puts "Invalid Records: #{invalid_count}"
    log_file.puts "Skipped or Duplicate Records: #{skipped_count}"
  end

  puts "#{model.name.pluralize} import completed. Check the log file at #{log_file_path} for details."
end

def transform_row(row, model)
  attributes = row.to_hash.slice(*model.column_names.map(&:to_s)).symbolize_keys

  # Custom transformations
  case model.name
  when 'Invoice'
    attributes[:status] = map_status(row['status']) if row['status']
  when 'Transaction'
    attributes[:credit_card_expiration_date] = parse_date(row['credit_card_expiration_date'])
    attributes[:result] = map_status(row['result']) if row['result']
  when 'InvoiceItem'
    attributes[:status] = map_status(row['status']) if row['status']
  end

  attributes
end

# Helper Methods

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
    Date.strptime(date_string, '%Y-%m-%d')
  rescue ArgumentError
    puts "Invalid date format: #{date_string}. Returning nil."
    nil
  end
end
