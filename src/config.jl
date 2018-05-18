using JSON

struct Config
    fn::String
    data::Dict{Any, Any}
end

function saveConfig(c::Config)
    path = dirname(c.fn)

    if !isdir(path)
        mkdir(path)
    end

    open(c.fn, "w") do fh
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

Base.getindex(c::Config, key::Any) = c.data[key]
Base.get(c::Config, key::K where K, value::V where V) = get(c.data, key, value)
Base.haskey(c::Config, key::String) = haskey(c.data, key)

function Base.setindex!(c::Config, value::V where V, key::K where K)
    c.data[key] = value
    saveConfig(c)
end