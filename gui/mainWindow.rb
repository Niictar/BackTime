class MainWindow
  def initialize(root_window, timesheet)
    TkToplevel.new(root_window) do
      width 500
      height 500
    end
  end
end
