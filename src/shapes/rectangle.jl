struct Rectangle
    x::Number
    y::Number
    w::Number
    h::Number
end

Base.:(==)(lhs::Rectangle, rhs::Rectangle) = lhs.x == rhs.x && lhs.y == rhs.y && lhs.w == rhs.w && lhs.h == rhs.h

# AABB check
function checkCollision(box1::Rectangle, box2::Rectangle)
    return (
        box1.x < box2.x + box2.w &&
        box1.x + box1.w > box2.x &&
        box1.y < box2.y + box2.h &&
        box1.y + box1.h > box2.y
    )
end

# Find top left corner and bottom right corner
function bounds(rects::Array{Rectangle, 1})
    tlx = tly = typemax(Int)
    brx = bry = typemin(Int)

    for rect in rects
        tlx = min(tlx, rect.x)
        tly = min(tly, rect.y)

        brx = max(brx, rect.x + rect.w)
        bry = max(bry, rect.y + rect.h)
    end

    return tlx, tly, brx, bry
end

# Rectangle that covers all input rectangles
function coverRectangles(rects::Array{Rectangle, 1})
    tlx, tly, brx, bry = bounds(rects)

    return Rectangle(tlx, tly, brx - tlx, bry - tly)
end