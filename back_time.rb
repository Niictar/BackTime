#!/usr/bin/ruby
require "yaml"
require_relative "gui"
require_relative "timesheet"
require_relative "time_analyzer"

module BackTime extend self
  attr_accessor :config
  @config_file = "config.yaml"
  @config = YAML.load_file @config_file

  # Persists the current configuration to the current configuration
  # file.
  def persist_config
    IO.write @config_file, @config.to_yaml
  end
end

Gui.new.start_graphical
