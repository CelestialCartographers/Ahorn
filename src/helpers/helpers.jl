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

function hasExt(fn::String, ext::String, ignorecase::Bool=Sys.iswindows())
    path, fnext = splitext(fn)

    if ignorecase
        return lowercase(fnext) == lowercase(ext)

    else
        return fnext == ext
    end
end

function humanizeVariableName(s::String) 
    text = replace(s, "_" => " ")
    text = replace(text,  "/" => " ")

    prevUpper = false
    nextLower = false
    len = length(s)

    res = Char[]

    for (i, c) in enumerate(text)
        thisUpper = isuppercase(c)
        nextLower = i < len && islowercase(text[i + 1])

        if thisUpper && !prevUpper
            push!(res, ' ')
        end

        if thisUpper && nextLower && res[end] != ' '
            push!(res, ' ')
        end

        prevUpper = thisUpper

        push!(res, c)
    end

    return titlecase(strip(join(res)))
end

function useIfApplicable(f, args...)
    if applicable(f, args...)
        f(args...)

        return true
    end

    return false
end

lerp(n::Number, m::Number, a::Number) = n + (n - m) * a