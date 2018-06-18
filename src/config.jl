using JSON

mutable struct Config
    fn::String
    data::Dict{Any, Any}
    mtime::Number
    buffertime::Number

    Config(fn::String, data::Dict{K, V}) where {K, V} = new(fn, data, 0, 0)
    Config(fn::String, buffertime::Number, data::Dict{K, V}) where {K, V} = new(fn, data, 0, buffertime)
end

function saveConfig(c::Config, force::Bool=true)
    if force || c.buffertime <= 0 || c.mtime + c.buffertime < time()
        path = dirname(c.fn)

        if !isdir(path)
            mkdir(path)
        end

        open(c.fn, "w") do fh
            c.mtime = time()
            JSON.print(fh, c.data, 4)
        end
    end
end

function loadConfig(fn::String, buffertime::Number=0, default::Dict{K, V}=Dict{Any, Any}()) where {K, V}
    if isfile(fn)
        return Config(fn, open(JSON.parse, fn))

    else
        config = Config(fn, default)
        saveConfig(config)

        return config
    end
end

setDefaults!(c::Config, d::Dict{K, V}) where {K, V} = c.data = merge(d, c.data)

Base.haskey(c::Config, key::String) = haskey(c.data, key)

function Base.setindex!(c::Config, value::V, key::K) where {K, V}
    prev = haskey(c, key)? c.data[key] : nothing
    c.data[key] = value

    if value != prev && prev === nothing
        saveConfig(c, false)
    end
end

function Base.getindex(c::Config, key::Any) 
    if mtime(c.fn) > c.mtime
        c.mtime = mtime(c.fn)
        c.data = open(JSON.parse, c.fn)
    end

    return c.data[key]
end

function Base.get(c::Config, key::K, value::V) where {K, V}
    if mtime(c.fn) > c.mtime
        c.mtime = mtime(c.fn)
        c.data = open(JSON.parse, c.fn)
    end

    # Force a rewrite of the config
    if !haskey(c.data, key)
        c[key] = value
    end

    return c.data[key]
end