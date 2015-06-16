#!/usr/bin/ruby
require "yaml"
require_relative "gui/gui"
require_relative "analysis/timesheet"
require_relative "analysis/time_analyzer"

module BackTime extend self
  attr_reader :config
  attr_accessor :args, :config_file

  @args = {}

  # Persists the current configuration to the current configuration
  # file.
  def persist_config
    IO.write @config_file, @config.to_yaml
  end

  def args=(args)
    @args = args
    @config_file = (args['-config'] or ["config.yaml"]).last
    @config = File.exists?(@config_file) ? (YAML.load_file(@config_file) or {}) : {}
    @config['database'] = args['-database'].last unless args['-database'].nil?
    @config['verbose'] = args['-v'].last unless args['-v'].nil?
  end
end

# Help screen
help = <<HELP
BackTime -- An incomplete thing you probably shouldn't be using.

General arguments:
    -config <file>  Use another YAML besides config.yaml as a config
    -database <db>  The SQLite database you wish to use
    -h              This Screen
    -gui            Display the nonexistent GUI
    -v              Makes queries verbose. (Slows things down too though)

Importing arguments:
    -ff     <file>  Imports a Firefox history database
    -chrome <file>  Imports a Google Chrome history database
    -iehv   <file>  Imports an Internet Explorer History Viewer XML file
    -file   <path>  Imports a filesystem path's creation, modification,
                    and access times into the database

Output options:
   -csv             Output the current database as a CSV
   -summary         Output a summary of contiguous time based on the
                    information in the database.
HELP

# Command line argument parsing
args = {}

# Finds pairs, and assigns them in the object... The entire expression
# will either return the last parameter or nil if the last parameter
# was a group. This is because inject stops when it no longer has two
# values left to play with.
last = ARGV.inject do |first, second|
  if first.nil?
    second
  elsif first[0] == "-" and second[0] != "-"
    args[first] = [] if args[first].nil?
    args[first] << second
    nil
  else
    args[first] = [true]
    second
  end
end

# ...that means, we assign it to true, but only if it is not nil.
args[last] = true unless last.nil?
BackTime.args = args

puts help and exit if args == {} or args['-h']

# Super-procedural and super-simple argument handling!
timesheet = TimeSheet.new BackTime.config['database']

args['-ff'].each do |file|
  puts "Importing Firefox database: #{file}"
  timesheet.add_firefox_history file
end if args['-ff']

args['-chrome'].each do |file|
  puts "Importing Chrome database: #{file}"
  timesheet.add_chrome_history file
end if args['-chrome']

args['-iehv'].each do |file|
  puts "Importing Internet Explorer History Viewer XML: #{file}"
  timesheet.add_iehv_xml file
end if args['-iehv']

args['-file'].each do |path|
  puts "Importing filesystem file times from #{path}"
  timesheet.add_folder path
end if args['-file']

puts timesheet.to_csv and exit if args['-csv']

analyzer = TimeAnalyzer.new timesheet
puts analyzer.time_summary and exit if args['-summary']

Gui.new.start_graphical if args['-gui']
