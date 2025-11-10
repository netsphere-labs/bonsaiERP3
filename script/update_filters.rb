#!/usr/bin/env ruby
# Script to update before_filter to before_action in controllers

require 'fileutils'

def process_file(file_path)
  puts "Processing: #{file_path}"
  content = File.read(file_path)
  
  # Replace before_filter with before_action
  updated_content = content.gsub(/before_filter/, 'before_action')
  updated_content = updated_content.gsub(/skip_before_filter/, 'skip_before_action')
  
  # Write the updated content back to the file
  File.write(file_path, updated_content)
  puts "Updated: #{file_path}"
end

# Process all controller files
Dir.glob(File.join(File.dirname(__FILE__), '../app/controllers/**/*.rb')).each do |file|
  process_file(file)
end

puts "All controllers updated successfully!"
