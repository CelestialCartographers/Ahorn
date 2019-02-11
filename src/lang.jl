@Maple.fieldproxy struct LangData <: AbstractDict{Symbol, Any}
    data::Dict{Symbol, Any}

    LangData(d::Dict{String, Any}) = new(Dict{Symbol, Any}(Symbol(k) => isa(v, Dict) ? LangData(v) : v for (k, v) in d))
    LangData(d::Dict{Symbol, Any}) = new(d)
    LangData() = new(Dict{Symbol, Any}())
end

Base.iterate(ld::LangData) = iterate(getfield(ld, :data))
Base.iterate(ld::LangData, i) = iterate(getfield(ld, :data), i)
Base.merge(ld::LangData, others::LangData...) = LangData(merge(getfield(ld, :data), getfield.(others, Ref(:data))...))

function Base.get(ld::LangData, parts::Array{Symbol, 1}, default::Any=LangData())
    target = ld

    for part in parts
        if !isa(target, LangData) || !haskey(getfield(target, :data), part)
            return default
        end
        
        target = getfield(target, :data)[part]
    end

    return target
end

Base.get(ld::LangData, parts::Array{String, 1}, default::Any=LangData()) = get(ld, Symbol.(parts), default)
Base.get(ld::LangData, key::Symbol) = get(ld, key, LangData())

function setDictPathValue!(d::Dict{String, Any}, parts::Array{String, 1}=String[], value::Any=nothing; allowOverwrite::Bool=false)
    target = d

    for part in parts[1:end - 1]
        if !haskey(target, part)
            target[part] = Dict{String, Any}()
        end

        target = target[part]
    end

    if !allowOverwrite || (allowOverwrite && haskey(target, parts[end]))
        target[parts[end]] = value
    end
end

function parseLangfile(s::String; init::Dict{String, Any}=Dict{String, Any}(), commentPrefix::String="#", assignment::String="=", seperator::String=".", allowOverwrite::Bool=false, stripValues::Bool=true)
    res = init

    replace(s, "\r\n" => "\n")

    for line in split(s, "\n")
        if !startswith(line, commentPrefix)
            parts = split(line, assignment)
            key, value = parts[1], join(parts[2:end], assignment)

            if stripValues
                value = convert(String, strip(value))
            end

            if !isempty(key) && !isempty(value)
                fieldParts = String.(split(key, seperator))
                setDictPathValue!(res, fieldParts, value, allowOverwrite=allowOverwrite)
            end
        end
    end

    return res
end

function expandTooltipText(s::String)
    # Replace \n with actuall newline
    # Strip leading/trailing whitespace from all lines

    s = replace(s, "\\n" => "\n")
    s = join(strip.(split(s, "\n")), "\n")

    return s
end

function loadLangfile()
    global langdata = LangData(loadLangdata())
end