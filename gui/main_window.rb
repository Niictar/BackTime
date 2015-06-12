require 'tk'
require_relative "config_window"

class MainWindow
  attr_reader :root_window, :analyzer
  attr_accessor :timesheet

  # Creates the main TK window
  def initialize
    @root_window = TkRoot.new do
      title "Time Analyzer"
    end

    config_window = ConfigWindow.new @root_window
    database = BackTime.config['database']

    if database.nil?
      @root_window.withdraw
      config_window.show
    end

    gui @root_window
  end

  # Starts the GUI
  # Seperate from the constructor in case you wish to do something
  # with this class first.
  def start
    Tk.mainloop
  end

  private
  # The Main GUI layout code.
  def gui(root)
    Tk::Tile::Frame.new(root) do
      padding "3 3 12 12"
      grid :sticky => "nesw"
    end
  end
end
