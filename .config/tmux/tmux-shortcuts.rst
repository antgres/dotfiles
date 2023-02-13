Tmux keyboard shortcuts
-----------------------

The default commands are activated per PREFIX (should be C-s)

- Close single pane
	PREFIX x [y|n]

- Close all panes in session
	PREFIX & [y|n]

- Switch between panes
	PREFIX [arrow keys]

- Add additonal horizontal -- pane
	PREFIX "

- Add additonal vertical | pane
	PREFIX %

- Enter copy mode
	PREFIX [ (or shortcut M-s)

- Search for word
	 PREFIX /

- Start/Stop to copy selected into buffer
	PREFIX [Space] (or shortcut M-a)

- Show all saved buffers
	$(tmux list-buffers)
