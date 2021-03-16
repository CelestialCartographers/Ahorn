using JSON

mutable struct Config
    fn::String
    data::Dict{Any, Any}
    mtime::Number
    buffertime::Number
    lastCheck::Number
    checkDelay::Number

    Config(fn::String, data::Dict{K, V}, checkDelay::Number=2.5) where {K, V} = new(fn, data, 0, 0, 0, checkDelay)
    Config(fn::String, buffertime::Number, data::Dict{K, V}, checkDelay::Number=2.5) where {K, V} = new(fn, data, 0, buffertime, 0, checkDelay)
end

function saveConfig(c::Config, force::Bool=true)
    if force || c.buffertime <= 0 || c.mtime + c.buffertime < time()
        path = dirname(c.fn)

        if !isdir(path)
            mkpath(path)
        end

        # Save to $fn.saving first, then delete fn and move the temp file
        # Prevents corruption of data if program is terminated while writing
        open(c.fn * ".saving", "w") do fh
            c.mtime = time()
            JSON.print(fh, c.data, 4)
        end

        mv(c.fn * ".saving", c.fn, force=true)
    end
end

function loadConfig(fn::String, buffertime::Number=0, default::Dict{K, V}=Dict{Any, Any}()) where {K, V}
    tempFn = fn * ".saving"

    # Program terminated before the config was moved
    # Temp file has correct data
    if !isfile(fn) && isfile(tempFn)
        mv(tempFn, fn)
    end

    # Delete any left over temp files
    # Program was terminated while config was saved
    if isfile(tempFn)
        rm(tempFn)
    end

    if isfile(fn)
        return Config(fn, buffertime, open(JSON.parse, fn))

    else
        config = Config(fn, buffertime, default)
        saveConfig(config)

        return config
    end
end

setDefaults!(c::Config, d::Dict{K, V}) where {K, V} = c.data = merge(d, c.data)

Base.haskey(c::Config, key::String) = haskey(c.data, key)

function Base.setindex!(c::Config, value::V, key::K) where {K, V}
    prev = haskey(c, key) ? c.data[key] : nothing
    c.data[key] = value

    if value != prev || prev === nothing
        saveConfig(c, false)
    end
end

function Base.getindex(c::Config, key::Any) 
    now = time()

    if now > c.lastCheck + c.checkDelay
        c.lastCheck = now

        if mtime(c.fn) > c.mtime
            c.mtime = mtime(c.fn)
            c.data = open(JSON.parse, c.fn)
        end
    end

    return c.data[key]
end

function Base.get(c::Config, key::K, value::V) where {K, V}
    now = time()

    if now > c.lastCheck + c.checkDelay
        c.lastCheck = now

        if mtime(c.fn) > c.mtime
            c.mtime = mtime(c.fn)
            c.data = open(JSON.parse, c.fn)
        end
    end

    # Force a rewrite of the config
    if !haskey(c.data, key)
        c[key] = value
    end

    return c.data[key]
end