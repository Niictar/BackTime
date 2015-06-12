require_relative 'main_window'

class Gui
  attr_accessor :log

  # Creates a visible Gui instance
  #
  # Accepts a single paramater to determine if you want to log to
  # standard out or not. true for yes, false for no. Default is false.
  def start_graphical
    MainWindow.new.start
  end
end
