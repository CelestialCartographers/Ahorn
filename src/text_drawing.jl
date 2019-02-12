function drawCenteredText(ctx::Cairo.CairoContext, s::String, x::Number, y::Number, width::Number, height::Number; font::Font=pico8Font, tint::Union{colorTupleType, Nothing}=colors.canvas_font_color)
    words = split(s, " ")
    lines::Array{String, 1} = split(words[end], "\n")
    minwidth = max(width - 8, 0)

    for (i, word) in enumerate(Iterators.drop(Iterators.reverse(words), 1))
        linewords = split(word, "\n")
        lastword = linewords[end]

        newline = lastword * " " * lines[1]
        linewidth = lineWidth(font, newline)

        if linewidth <= minwidth
            lines[1] = newline

        else
            pushfirst!(lines, lastword)
        end

        for remainingword in Iterators.drop(Iterators.reverse(linewords), 1)
            pushfirst!(lines, remainingword)
        end
    end

    drawText = join(lines, "\n")
    widest, tallest = size(font, drawText)

    cx, cy = round(Int, x + (width - widest) / 2), round(Int, y + (height - tallest) / 2)
    drawString(ctx, font, drawText, cx, cy, align=:center, tint=tint)
end