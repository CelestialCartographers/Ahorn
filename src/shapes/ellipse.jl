struct Ellipse
    x::Number
    y::Number

    rh::Number
    rv::Number
end

Base.:(==)(lhs::Ellipse, rhs::Ellipse) = lhs.x == rhs.x && lhs.y == rhs.y && lhs.rv == rhs.rv && lhs.rh == rhs.rh

# Efficient enough, checks might be too small for huge circles
function pointsOnEllipse(ellipse::Ellipse; filled::Bool=false, checks::Int=180)
    res = Set{Tuple{Number, Number}}()
    step = 2 * pi / checks

    for theta in 0:step:2 * pi
        ox = cos(theta) * ellipse.rh
        oy = sin(theta) * ellipse.rv

        push!(res, (round(Int, ellipse.x + ox), round(Int, ellipse.y + oy)))
        push!(res, (round(Int, ellipse.x - ox), round(Int, ellipse.y + oy)))

        if filled
            for i in floor(Int, -ox + 1):ceil(Int, ox - 1)
                push!(res, (round(Int, ellipse.x + i), round(Int, ellipse.y + oy)))
            end
        end
    end

    return collect(res)
end