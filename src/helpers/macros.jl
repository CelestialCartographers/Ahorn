macro catchall(expr)
    quote 
        try
            $(expr |> esc)

        catch e
            println(Base.stderr, e)
            println.(Ref(Base.stderr), stacktrace())
            println(Base.stderr, "---")
        end
    end
end