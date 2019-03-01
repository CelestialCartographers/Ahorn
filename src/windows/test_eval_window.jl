module TestEvalWindow

using Gtk, Gtk.ShortNames, Gtk.GConstants
using ..Ahorn, Maple

evalWindow = nothing

function evalCode(button, textField)
    text = Ahorn.getTextViewText(textField)

    @Ahorn.catchall begin
        expr = Meta.parse("begin;" * strip(text) * "; end")
        res = Base.eval(Ahorn, expr)

        if res !== nothing
            println(res)
        end
    end
end

function spawnWindowIfAbsent!()
    if evalWindow === nothing
        global evalWindow = createWindow()
    end
end

function hideEvalWindow(widget=nothing, event=nothing)
    spawnWindowIfAbsent!()
    visible(evalWindow, false)

    return true
end

function showEvalWindow(widget=nothing, event=nothing)
    spawnWindowIfAbsent!()
    visible(evalWindow, true)
    present(evalWindow)

    return true
end

function createWindow()
    evalWindow = Window("$(Ahorn.baseTitle) - Test Console", 720, 480, true, icon = Ahorn.windowIcon, gravity = GdkGravity.GDK_GRAVITY_CENTER
    ) |> (Frame() |> (evalBox = Box(:v)))

    # Hide window instead of destroying it
    signal_connect(hideEvalWindow, evalWindow, "delete_event")
   
    evalGrid = Ahorn.Grid()
    evalInputField = TextView(
        vexpand=true,
        hexpand=true,
        monospace=true
    )
    
    evalButton = Button("Eval", hexpand=true)
    signal_connect(widget -> evalCode(evalButton, evalInputField), evalButton, "clicked")
    
    scrollableInputField = ScrolledWindow(vexpand=true, hexpand=true)
    push!(scrollableInputField, evalInputField)
    
    evalGrid[1, 1] = scrollableInputField
    evalGrid[1, 2] = evalButton

    push!(evalBox, evalGrid)
    showall(evalWindow)

    return evalWindow
end

end