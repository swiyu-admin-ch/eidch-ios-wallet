#!/usr/bin/env ruby
# frozen_string_literal: true

STRINGS_DIRECTORY = 'Modules/Platforms/BITL10n/Sources/BITL10n/Resources'

KEY_LINE_REGEX = /^\s*"(.+?)"\s*=\s*".*";\s*$/

def remove_duplicates_from_file(file_path)
  lines = File.readlines(file_path, encoding: 'UTF-8')
  seen_keys = {}
  removed_count = 0
  removed_keys = []

  new_lines = lines.filter_map do |line|
    match = KEY_LINE_REGEX.match(line)
    if match
      key = match[1]
      if seen_keys.key?(key)
        removed_count += 1
        removed_keys << key
        nil
      else
        seen_keys[key] = true
        line
      end
    else
      line
    end
  end

  File.write(file_path, new_lines.join, encoding: 'UTF-8')

  if removed_count.positive?
    puts "Removed #{removed_count} duplicate keys from #{file_path}."
    removed_keys.uniq.each { |key| puts "  #{key}" }
  else
    puts "No duplicate keys found in #{file_path}."
  end
end

def main
  pattern = File.join(STRINGS_DIRECTORY, '*.lproj', '*.strings')
  Dir.glob(pattern).each do |file_path|
    remove_duplicates_from_file(file_path)
  end
end

main if __FILE__ == $PROGRAM_NAME
