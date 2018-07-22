guessValidationFunction(v::Number) = isNumber
guessValidationFunction(v::Any) = (v) -> true

validationPassedIcon = ""
validationFailedIcon = "edit-delete"

function ValidationEntry(value::Any, validation::Function=guessValidationFunction(value), placeholder::String=string(value); setPlaceholder::Bool=true)
    text = string(value)
    entry = Entry(text=text)

    if setPlaceholder
        setproperty!(entry, :placeholder_text, placeholder)
    end

    icon = validation(text)? validationPassedIcon : validationFailedIcon
    setproperty!(entry, :primary_icon_name, icon)

    @guarded signal_connect(entry, "changed") do widget
        text = getproperty(widget, :text, String)
        icon = validation(text)? validationPassedIcon : validationFailedIcon

        setproperty!(widget, :primary_icon_name, icon)
    end

    return entry
end