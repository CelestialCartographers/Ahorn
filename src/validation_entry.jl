guessValidationFunction(v::Number) = isNumber
guessValidationFunction(v::Any) = (v) -> true

validationPassedIcon = ""
validationFailedIcon = "edit-delete-symbolic"

function ValidationEntry(value::Any, validation::Function=guessValidationFunction(value), placeholder::String=string(value); setPlaceholder::Bool=true)
    text = string(value)
    entry = Entry(text=text)

    if setPlaceholder
        GAccessor.placeholder_text(entry, placeholder)
    end
    
    icon = validation(text) ? validationPassedIcon : validationFailedIcon
    set_gtk_property!(entry, :secondary_icon_name, icon)

    @guarded signal_connect(entry, "changed") do widget
        text = Gtk.bytestring(GAccessor.text(widget))
        icon = validation(text) ? validationPassedIcon : validationFailedIcon

        set_gtk_property!(widget, :secondary_icon_name, icon)
    end

    return entry
end