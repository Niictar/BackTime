require 'tk'

root = TkRoot.new do
  resizable false, false
  title "Retrospective Timesheet setup"
end


selection = TkFrame.new(root) do
  grid :row => 0, :column => 0
end

TkLabel.new(selection) do
   text "Database:"
   height 3
   padx 5
   grid :row => 0, :column => 0
end

database = TkText.new(selection) do
  width 30
  height 1
  grid :row => 0, :column => 1
end

TkButton.new(selection) do
  text "Select"
  width 7
  grid :row => 0, :column => 2, :padx => 7
  command do
    selected = getOpenFile
    database.value = selected unless selected.empty?
  end
end

frame = TkFrame.new(selection) do
  pady 5
  borderwidth 1
  relief "solid"
  background "grey"
  grid :row => 1, :column => 0, :columnspan => 3, :sticky => "ew"
end

TkButton.new(frame) do
  text "Ok"
  width 7
  pack :side => "right", :padx => 5
end

TkButton.new(frame) do
  text "Cancel"
  width 7
  pack :side => "right"
  command {root.destroy}
end

Tk.mainloop