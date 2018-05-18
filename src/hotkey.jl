# TODO - More userfriendly registering
struct Hotkey
    key::Integer
    callback::Function
    conditions::Array{Function, 1}

    Hotkey(key::Integer, callback::Function, modifiers::Array{Function, 1}) = new(key, callback, modifiers)
    Hotkey(key::Char, callback::Function, modifiers::Array{Function, 1}) = new(Int(key), callback, modifiers)
end

callback(h::Hotkey, args...) = h.callback(args...)
active(h::Hotkey, event::Gtk.GdkEventKey) = event.keyval == h.key && all((f -> f()).(h.conditions))