struct SimpleCurve
    start::Tuple{Number, Number}
    stop::Tuple{Number, Number}
    control::Tuple{Number, Number}

    SimpleCurve(start::Tuple{Number, Number}, stop::Tuple{Number, Number}, control::Tuple{Number, Number}=(start .+ stop) ./ 2) = new(start, stop, control)
end

function getPoint(curve::SimpleCurve, percent::Number)
    x = (1 - percent)^2 * curve.start[1] + 2 * (1 - percent) * percent * curve.control[1] + percent^2 * curve.stop[1]
    y = (1 - percent)^2 * curve.start[2] + 2 * (1 - percent) * percent * curve.control[2] + percent^2 * curve.stop[2]

    return x, y
end