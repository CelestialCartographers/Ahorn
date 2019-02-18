struct Circle
    x::Number
    y::Number

    r::Number

    Circle(x::Number, y::Number, r::Number) = new(x, y, r)
    Circle(x1::Number, y1::Number, x2::Number, y2::Number) = new(x1, y1, sqrt((x1 - x2)^2 + (y1 - y2)^2))
end

function circumference(circle::Circle)
    return 2 * pi * circle.r
end

Base.:(==)(lhs::Circle, rhs::Circle) = lhs.x == rhs.x && lhs.y == rhs.y && lhs.r == rhs.r

# Efficient enough, checks might be too small for huge circles
function pointsOnCircle(circle::Circle; filled::Bool=false, checks::Int=max(1, ceil(Int, circumference(circle))))
    res = Set{Tuple{Number, Number}}()
    step = 2 * pi / checks

    if checks > 0
        for theta in 0:step:2 * pi
            ox = cos(theta) * circle.r
            oy = sin(theta) * circle.r

            push!(res, (round(Int, circle.x + ox), round(Int, circle.y + oy)))
            push!(res, (round(Int, circle.x - ox), round(Int, circle.y + oy)))

            if filled
                for i in floor(Int, -ox + 1):ceil(Int, ox - 1)
                    push!(res, (round(Int, circle.x + i), round(Int, circle.y + oy)))
                end
            end
        end
    end

    return collect(res)
end