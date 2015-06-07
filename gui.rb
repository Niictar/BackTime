require 'tk'
require_relative 'gui/configWindow'

class Gui
  attr_reader :root_window

  def initialize
    @root_window = TkRoot.new.withdraw
    ConfigWindow.new @root_window
    Tk.mainloop
  end
end
