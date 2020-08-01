function fastZipFileRead(file, T)
    bytes = file.uncompressedsize
    v = Vector{UInt8}(undef, bytes)

    # Directories have 0 bytes, ignore
    if bytes > 0
        read!(file, v)
    end

    return T(v)
end

function fastZipFileRead(file)
    bytes = file.uncompressedsize
    v = Vector{UInt8}(undef, bytes)

    # Directories have 0 bytes, ignore
    if bytes > 0
        read!(file, v)
    end

    return v
end