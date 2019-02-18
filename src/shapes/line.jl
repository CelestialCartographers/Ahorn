const tolerance = 10.0^-10

struct Line
    x1::Number
    y1::Number

    x2::Number
    y2::Number
end

Base.:(==)(lhs::Line, rhs::Line) = lhs.x1 == rhs.x1 && lhs.y1 == rhs.y1 && lhs.x2 == rhs.x2 && lhs.y2 == rhs.y2

# How much is missing to get to the closest new "grid square"
function rayDelta(n, a)
    s = sign(a)

    if s > 0
        return floor(n + 1) - n

    elseif s < 0
        return ceil(n - 1) - n

    else
        return 0
    end
end

function pointsOnLine(line::Line)
    x1, y1, x2, y2 = line.x1, line.y1, line.x2, line.y2
    res = Set{Tuple{Number, Number}}()
    theta = atan(y2 - y1, x2 - x1)

    x, y = x1, y1

    velX = cos(theta)
    velY = sin(theta)

    velX = isapprox(velX, 0, atol=tolerance) ? 0 : velX
    velY = isapprox(velY, 0, atol=tolerance) ? 0 : velY

    while velX != 0 && !isapprox(x, x2, atol=tolerance) || velY != 0 && !isapprox(y, y2, atol=tolerance)
        dx = rayDelta(x, velX)
        dy = rayDelta(y, velY)

        a = isnan(dx / velX) ? Inf : dx / velX
        b = isnan(dy / velY) ? Inf : dy / velY

        if a < b
            x += dx
            y += a * velY

        else
            x += b * velX
            y += dy
        end

        fx = floor(Int, x)
        fy = floor(Int, y)
        
        push!(res, (fx, fy))
    end

    push!(res, (x1, y1))
    push!(res, (x2, y2))

    return collect(res)
end