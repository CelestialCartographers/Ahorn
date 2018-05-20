using JSON

mutable struct Config
    fn::String
    data::Dict{Any, Any}
    mtime::Number

    Config(fn::String, data::Dict{K, V}) where {K, V} = new(fn, data, time())
end

function saveConfig(c::Config)
    path = dirname(c.fn)

    if !isdir(path)
        mkdir(path)
    end

    open(c.fn, "w") do fh
        c.mtime = time()
        JSON.print(fh, c.data, 4)
    end
end

function loadConfig(fn::String, default::Dict{K, V}=Dict{Any, Any}()) where {K, V}
    if isfile(fn)
        return Config(fn, open(JSON.parse, fn))

    else
        config = Config(fn, default)
        saveConfig(config)

        return config
    end
end

setDefaults!(c::Config, d::Dict{K, V}) where {K, V} = c.data = merge(d, c.data)

Base.get(c::Config, key::K where K, value::V where V) = get(c.data, key, value)
Base.haskey(c::Config, key::String) = haskey(c.data, key)

function Base.setindex!(c::Config, value::V where V, key::K where K)
    c.data[key] = value
    saveConfig(c)
end

function Base.getindex(c::Config, key::Any) 
    if mtime(c.fn) > c.mtime
        c.mtime = mtime(c.fn)
        c.data = open(JSON.parse, c.fn)
    end

    return c.data[key]
end

function Base.get(c::Config, key::K where K, value::V where V)
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