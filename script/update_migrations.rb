#!/usr/bin/env ruby
# Script to update migration files to specify Rails 5.2 version

require 'fileutils'

# Get all migration files
migration_files = Dir.glob(File.join(File.dirname(__FILE__), '../db/migrate/*.rb'))

migration_files.each do |file|
  content = File.read(file)
  
  # Skip if already has a version specified
  next if content.match?(/ActiveRecord::Migration\[\d+\.\d+\]/)
  
  # Replace the migration class definition
  updated_content = content.gsub(/class\s+(\w+)\s+<\s+ActiveRecord::Migration/, 'class \1 < ActiveRecord::Migration[5.2]')
  
  # Write the updated content back to the file
  File.write(file, updated_content)
  
  puts "Updated: #{File.basename(file)}"
end

puts "Migration update completed!"
