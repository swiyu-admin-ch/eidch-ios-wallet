#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

STRINGS_DIRECTORY = 'Modules/Platforms/BITL10n/Sources/BITL10n/Resources'

def sort_strings_file(file_path)
  lines = File.readlines(file_path, encoding: 'UTF-8')

  # Separate translatable entries from comments/empty lines
  entries = []
  others  = []

  lines.each do |line|
    stripped = line.strip
    if !stripped.empty? && !stripped.start_with?('//') && line.include?('=')
      entries << line
    else
      others << line
    end
  end

  entries.sort_by! { |entry| entry.split('=').first.strip }

  keys = entries.map { |entry| entry.split('=').first.strip }
  duplicate_keys = keys.select { |k| keys.count(k) > 1 }.uniq

  File.open(file_path, 'w:UTF-8') do |f|
    others.each { |line| f.write(line) }
    entries.each { |entry| f.write(entry) }
  end

  unless duplicate_keys.empty?
    puts "Duplicate keys in #{file_path}:"
    duplicate_keys.each { |key| puts key }
    raise "Duplicates found, see output above"
  end
end

def main
  pattern = File.join(STRINGS_DIRECTORY, '*.lproj', '*.strings')
  Dir.glob(pattern).each do |file_path|
    puts "Sorting: #{file_path}"
    sort_strings_file(file_path)
  end
end

main if __FILE__ == $PROGRAM_NAME
