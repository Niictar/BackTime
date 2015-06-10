require 'tk'
require_relative 'gui/configWindow'
require_relative 'gui/mainWindow'
require_relative 'timesheet'

class Gui
  attr_reader :root_window

  # Creates a visible Gui instance
  #
  # Accepts a single paramater to determine if you want to log to
  # standard out or not. true for yes, false for no. Default is false.
  def initialize(log = false)
    main_window = MainWindow.new true

    ConfigWindow.new main_window.root_window do |database_file|
      main_window.timesheet = TimeSheet.new database_file, log
      main_window.show
    end

    Tk.mainloop
  end
end
