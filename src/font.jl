struct Font
    surface::Cairo.CairoSurface
    charDict::Dict{Char, Tuple{Int, Int, Int, Int}}
    charSpacing::Int
    lineSpacing::Int

    Font(filename::String, fontString::String, charSpacing::Int=1, lineSpacing::Int=1) = new(open(Cairo.read_from_png, filename), generateFontDict(fontString), charSpacing, lineSpacing)
end

stringLineAlignOffsets = Dict{Symbol, Function}(
    :left => (widest, width) -> 0,
    :center => (widest, width) -> round(Int, (widest - width) / 2),
    :right => (widest, width) -> widest - width,
)

function getQuadTuple(row::Int, col::Int, width::Int=3, height::Int=5)
    return (8 * row - 8, 8 * col - 8, width, height)
end

# Use first occurance of a symbol as the target quad
function generateFontDict(fontString::String)
    fontMap = Dict{Char, Tuple{Int, Int, Int, Int}}()

    for (i, row) in enumerate(split(fontString, "\n"))
        for (j, c) in enumerate(row)
            get!(fontMap, c) do
                getQuadTuple(j, i, 3, 5)
            end
        end
    end

    return fontMap
end

# Multiline string
function lineWidth(font::Font, s::AbstractString, replaceMissing::Char=' ')
    return isempty(s) ? 0 : sum([get(font.charDict, c, font.charDict[replaceMissing])[3] for c in s]) + (length(s) - 1) * font.charSpacing
end

function lineHeight(font::Font, s::AbstractString, replaceMissing::Char=' ')
    return isempty(s) ? 0 : maximum([get(font.charDict, c, font.charDict[replaceMissing])[4] for c in s])
end

function Base.size(font::Font, s::AbstractString, replaceMissing::Char=' ')
    lines = split(s, "\n")

    width = maximum(lineWidth.(Ref(font), lines))
    height = sum(lineHeight.(Ref(font), lines)) + (length(lines) - 1) * font.lineSpacing

    return width, height
end

function drawString(ctx::Cairo.CairoContext, font::Font, s::AbstractString, x::Int=0, y::Int=0; scale::Number=1, replaceMissing::Char=' ', align::Symbol=:left, tint::Union{colorTupleType, Nothing}=colors.canvas_font_color)
    shouldSave = x != 0 || y != 0 || scale != 1

    if shouldSave
        Cairo.save(ctx)
        Cairo.translate(ctx, x, y)
        Cairo.scale(ctx, scale, scale)
    end

    accX = 0
    accY = 0

    lineAllignFunc = get(stringLineAlignOffsets, align, :left)
    widest, height = size(font, s, replaceMissing)

    for line in split(s, "\n")
        width = lineWidth(font, line, replaceMissing)
        accX = lineAllignFunc(widest, width)

        for c in line
            quadX, quadY, width, height = get(font.charDict, c, font.charDict[replaceMissing])
            drawImage(ctx, font.surface, accX, accY, quadX, quadY, width, height, tint=tint)

            accX += width + font.charSpacing
        end

        accY += lineHeight(font, line, replaceMissing) + font.lineSpacing
    end

    if shouldSave
        Cairo.restore(ctx)
    end
end

const pico8FontString = raw"""
                
                
 !"#$% ´()*+,-./
0123456789:;<=>?
@abcdefghijklmno
pqrstuvwxyz[\]^_
`ABCDEFGHIJKLMNO
PQRSTUVWXYZ{|}~ 
"""

const pico8Font = Font(abs"../assets/pico8_font.png", pico8FontString)