rgbTupleType = NTuple{3, Float64}
rgbaTupleType = NTuple{4, Float64}
colorTupleType = Union{rgbTupleType, rgbaTupleType}

ARGB(r, g, b, a) = reinterpret(Cairo.ARGB32, UInt32(a)<<24 | UInt32(b)<<16 | UInt32(g)<<8 | UInt32(r))

function argb32ToRGBATuple(n::Integer)
    return ((n >> 16) & 255, (n >> 8) & 255, n & 255, (n >> 24) & 255)
end

function normRGBA32Tuple2ARGB32(c::rgbaTupleType)
    bytes = round.(Int, c .* 255)

    return bytes[1] << 16 | bytes[2] << 8 | bytes[3] | bytes[4] << 24
end