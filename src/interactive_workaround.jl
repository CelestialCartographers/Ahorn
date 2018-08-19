function interactiveWorkaround(window::Gtk.GtkWindow)
    # If used outside of REPL this keeps the program running until the window is closed
    if !isinteractive()
        c = Condition()
        signal_connect(window, :destroy) do widget
            notify(c)
        end
        wait(c)
    end
end