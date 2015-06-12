require 'tk'
require_relative "config_window"

class MainWindow
  attr_reader :root_window, :analyzer
  attr_accessor :timesheet

  # Creates the main TK window
  # Accepts one argument that allows you to start this window hidden
  # or not. true for hidden, false otherwise. Default is visible.
  def initialize(log = false)
    @root_window = TkRoot.new do
      title "Time Analyzer"
    end

    if (config = BackTime.config)
      database = config['database']
    else
      BackTime.config = {}
    end

    if database.nil?
      @root_window.withdraw
      ConfigWindow.new @root_window do |database_file|
        @timesheet = TimeSheet.new database_file

        BackTime.config['database'] = database_file
        BackTime.persist_config

        @root_window.deiconify
      end
    else
      @timesheet = TimeSheet.new database
    end

    gui @root_window
  end

  def start
    Tk.mainloop
  end

  private
  def gui(root)
    Tk::Tile::Frame.new(root) do
      padding "3 3 12 12"
      grid :sticky => "nesw"
    end
  end
end
