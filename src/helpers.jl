# Prefer to parse as integer, parse as float if not
function parseNumber(n::String)
    try
        return parse(Int, n)

    catch ArgumentError
        return parse(Float64, n)
    end
end

# Base.isnumber doesn't cover floats
function isNumber(n::String)
    try
        parseNumber(n)

        return true

    catch ArgumentError
        return false
    end
end

function setEntryText!(entry::Gtk.GtkEntryLeaf, value::Any; updatePlaceholder::Bool=true)
    text = string(value)

    setproperty!(entry, :text, text)

    if updatePlaceholder
        setproperty!(entry, :placeholder_text, text)
    end
end