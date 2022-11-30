Tmux keyboard shortcuts
-----------------------

The default commands are activated per C-b, I switched it for C-a

- Close single pane
	C-a x [y|n]

- Close all panes in session
	C-a & [y|n]

- Switch between panes
	C-a [arrow keys]

- Add additonal horizontal -- pane
	C-a "

- Add additonal vertical | pane
	C-a %

- Enter copy mode
	C-a [

--- Search for word
	C-a s

--- Start/Stop to copy selected into buffer
	C-a [Space]

--- Show all saved buffers
	$(tmux list-buffers)
