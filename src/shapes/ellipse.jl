struct Ellipse
    x::Number
    y::Number

    rh::Number
    rv::Number
end

function circumference(ellipse::Ellipse)
    return pi * (3 * (ellipse.rh + ellipse.rv) - sqrt(10 * ellipse.rh * ellipse.rv + 3 * (ellipse.rh^2 + ellipse.rv^2)))
end

Base.:(==)(lhs::Ellipse, rhs::Ellipse) = lhs.x == rhs.x && lhs.y == rhs.y && lhs.rv == rhs.rv && lhs.rh == rhs.rh

ellipse_t(theta, e::Ellipse) = atan(e.rh / e.rv * tan(theta))

ellipse_f(t, e::Ellipse) = sqrt(e.rh^2 * sin(t)^2 + e.rv^2 * cos(t)^2)

# Calculates step size based on estimated arc length at current section compared to the 'optimum'.
# https://math.stackexchange.com/questions/433094/how-to-determine-the-arc-length-of-ellipse
function pointsOnEllipse(ellipse::Ellipse; filled::Bool=false, checks::Int=max(180, ceil(Int, circumference(ellipse) / 2)))
    res = Set{Tuple{Number, Number}}()
    step = 2 * pi / checks

    if checks > 0
        theta = -pi / 2
        while theta <= pi / 2
            ox = cos(theta) * ellipse.rh
            oy = sin(theta) * ellipse.rv

            push!(res, (round(Int, ellipse.x + ox), round(Int, ellipse.y + oy)))
            push!(res, (round(Int, ellipse.x - ox), round(Int, ellipse.y + oy)))

            if filled
                for i in floor(Int, -ox + 1):ceil(Int, ox - 1)
                    push!(res, (round(Int, ellipse.x + i), round(Int, ellipse.y + oy)))
                end
            end

            t = ellipse_t(theta, ellipse)
            f = ellipse_f(t, ellipse)
            mr = step * f
            theta += min(step / mr, step)
        end
    end

    return collect(res)
end