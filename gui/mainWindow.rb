class MainWindow
  attr_reader :root_window, :analyzer
  attr_accessor :timesheet

  # Creates the main TK window
  # Accepts one argument that allows you to start this window hidden
  # or not. true for hidden, false otherwise. Default is visible.
  def initialize(hidden = false)
    @root_window = TkRoot.new do
      title "Time Analyzer"
      width 500
      height 500
    end

    hide if hidden
  end

  # Shows the main window
  def show
    @root_window.deiconify
  end

  # Hides the main window
  def hide
    @root_window.withdraw
  end

  # Assigns the timesheet to the passed in value and creates an
  # analyzer for it.
  def timesheet=(timesheet)
    @timesheet = timesheet
    @analyzer = TimeAnalyzer.new timesheet
  end
end
