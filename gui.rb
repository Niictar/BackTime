require_relative 'gui/main_window'

class Gui
  attr_accessor :log

  def initialize(log = false)
    @log = log
  end

  # Creates a visible Gui instance
  #
  # Accepts a single paramater to determine if you want to log to
  # standard out or not. true for yes, false for no. Default is false.
  def start_graphical
    MainWindow.new(@log).start
  end
end
