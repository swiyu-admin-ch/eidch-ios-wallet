#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'
require 'fileutils'

ROOT_PROJECT_DIRECTORY = '..'
PROJECTS = ['Modules', 'swiyu']
L10N_RESOURCES_DIRECTORY = File.join(ROOT_PROJECT_DIRECTORY, 'Modules/Platforms/BITL10n/Sources/BITL10n/Resources')

def get_all_swift_files(project_dir)
  PROJECTS.flat_map do |project|
    Dir.glob(File.join(project_dir, project, '**', '*.swift'))
  end
end

def get_used_text_keys(swift_files)
  key_pattern = /L10n\.([A-Za-z0-9_]+)/
  used_keys = Set.new

  swift_files.each do |file|
    content = File.read(file, encoding: 'UTF-8')
    content.scan(key_pattern) { |match| used_keys << match.first.downcase }
  end

  used_keys
end

def to_camel_case(str)
  str.downcase.delete('_').delete(':').delete(' ')
end

def remove_unused_keys(strings_file, used_keys)
  lines = File.readlines(strings_file, encoding: 'UTF-8')
  removed = 0

  new_lines = lines.filter_map do |line|
    if line =~ /^"(.+?)"\s*=\s".*";$/
      key = to_camel_case(Regexp.last_match(1))
      if used_keys.include?(key)
        line
      else
        removed += 1
        nil
      end
    else
      line
    end
  end

  File.write(strings_file, new_lines.join, encoding: 'UTF-8')
  puts "Removed #{removed} unused keys from #{strings_file}."
end

def main
  swift_files = get_all_swift_files(ROOT_PROJECT_DIRECTORY)
  puts "Found #{swift_files.size} Swift files."

  strings_files = Dir.children(L10N_RESOURCES_DIRECTORY)
                    .select { |f| f.end_with?('.lproj') }
                    .map { |f| File.join(L10N_RESOURCES_DIRECTORY, f, 'Localizable.strings') }

  used_keys = get_used_text_keys(swift_files)
  puts "Found #{used_keys.size} used text keys."

  strings_files.each { |file| remove_unused_keys(file, used_keys) }
end

main if __FILE__ == $PROGRAM_NAME
