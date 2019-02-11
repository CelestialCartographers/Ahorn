struct SimpleCurve
    start::Tuple{Number, Number}
    stop::Tuple{Number, Number}
    control::Tuple{Number, Number}

    SimpleCurve(start::Tuple{Number, Number}, stop::Tuple{Number, Number}, control::Tuple{Number, Number}=(start .+ stop) ./ 2) = new(start, stop, control)
end

function getPoint(curve::SimpleCurve, percent::Number)
    return (1 - percent)^2 .* curve.start .+ 2 .* (1 - percent) * percent .* curve.control .+ percent^2 .* curve.stop
end