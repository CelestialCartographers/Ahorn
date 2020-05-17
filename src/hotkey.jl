# Saner way to get modifier keys in tools
modifierControl() = keyHeld(Gtk.GdkKeySyms.Control_L) || keyHeld(Gtk.GdkKeySyms.Control_R)
modifierShift() = keyHeld(Gtk.GdkKeySyms.Shift_L) || keyHeld(Gtk.GdkKeySyms.Shift_R)
modifierMeta() = keyHeld(Gtk.GdkKeySyms.Meta_L) || keyHeld(Gtk.GdkKeySyms.Meta_R)
modifierAlt() = keyHeld(Gtk.GdkKeySyms.Alt_L) || keyHeld(Gtk.GdkKeySyms.Alt_R)
modifierSuper() = keyHeld(Gtk.GdkKeySyms.Super_L) || keyHeld(Gtk.GdkKeySyms.Super_R)
modifierHyper() = keyHeld(Gtk.GdkKeySyms.Hyper_L) || keyHeld(Gtk.GdkKeySyms.Hyper_R)

const modifierNames = Dict{String, Function}(
    "ctrl" => modifierControl,
    "shift" => modifierShift,
    "alt" => modifierAlt,
    "super" => modifierSuper,
    "win" => modifierSuper,
    "hyper" => modifierHyper,
    "meta" => modifierMeta
)

struct Hotkey
    key::Integer
    callback::Function
    conditions::Array{Function, 1}

    Hotkey(key::Integer, callback::Function, modifiers::Array{Function, 1}) = new(key, callback, modifiers)
    Hotkey(key::Char, callback::Function, modifiers::Array{Function, 1}) = new(Int(key), callback, modifiers)
end

# Allow "keyword" charcters like Delete, Enter, etc
function Hotkey(s::String, callback::Function,  modifiers::Array{Function, 1}=Function[])
    key = -1

    words = strip.(split(s, "+"))

    for (i, word) in enumerate(words)
        if i < length(words)
            if haskey(modifierNames, word)
                push!(modifiers, modifierNames[word])

            else
                println(Base.stderr, "Invalid hotkey sequence")

                return nothing
            end
        end

        if i == length(words)
            if length(word) == 1
                key = Int(word[1])
            
            # This is case sensitive!
            # Use values from Gtk.GdkKeySyms
            elseif isdefined(Gtk.GdkKeySyms, Symbol(word))
                key = getfield(Gtk.GdkKeySyms, Symbol(word))

            else
                println(Base.stderr, "Invalid hotkey sequence")
                
                return nothing
            end
        end
    end

    return Hotkey(key, callback, modifiers)
end

callback(h::Hotkey, args...) = h.callback(args...)

function active(h::Hotkey, event::Gtk.GdkEventKey)
    keyMeet = lowercase(Char(h.key)) == lowercase(Char(event.keyval))
    allModifiers = all((f -> f()).(h.conditions))

    return keyMeet && allModifiers
end

function callbackFirstActive(hotkeys::Array{Hotkey, 1}, event::Gtk.GdkEventKey)
    for hotkey in hotkeys
        if active(hotkey, event)
            return callback(hotkey)
        end
    end

    return false
end