require 'tk'
require_relative 'gui/configWindow'
require_relative 'gui/mainWindow'
require_relative 'timesheet'

class Gui
  attr_reader :root_window

  def initialize(log = false)
    @root_window = TkRoot.new do
      width 500
      height 500
    end.withdraw

    ConfigWindow.new @root_window do |database_file|
      MainWindow.new @root_window, TimeSheet.new(database_file, log)
    end

    Tk.mainloop
  end
end
