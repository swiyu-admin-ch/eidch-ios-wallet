#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'fileutils'
require 'tempfile'

STRINGS_DIRECTORY = 'Modules/Platforms/BITL10n/Sources/BITL10n/Resources'
LINE_REGEX = /^\s*"(?:[^"]|\\")+"\s*=\s*"(?:[^"]|\\")*";\s*$/

def sort_strings_file(file_path)
  Tempfile.create(file_path) do |old_file|
    File.open(file_path, 'rb') do |file|
      IO.copy_stream(file, old_file)
    end
    lines = File.readlines(file_path, encoding: 'UTF-8')

    # Separate translatable entries from comments/empty lines
    entries = []
    others  = []

    lines.each do |line|
      stripped = line.strip
      if !stripped.empty? && !stripped.start_with?('//') && line.include?('=')
        unless LINE_REGEX.match?(line)
          raise "Invalid format in line: #{line}"
        end
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
    !FileUtils.identical?(old_file, file_path)
  end
end

def main
  strict = ARGV.include?('--strict')
  pattern = File.join(STRINGS_DIRECTORY, '*.lproj', '*.strings')
  did_change = false
  Dir.glob(pattern).each do |file_path|
    puts "Sorting: #{file_path}"
    did_change = sort_strings_file(file_path) || did_change
  end
  raise "Files were unsorted, should be fixed now" if did_change && strict
end

main if __FILE__ == $PROGRAM_NAME
