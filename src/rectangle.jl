struct Rectangle
    x::Number
    y::Number
    w::Number
    h::Number
end

Base.isequal(lhs::Rectangle, rhs::Rectangle) = lhs.x == rhs.x && lhs.y == rhs.y && lhs.w == rhs.w && lhs.h == rhs.h

# AABB check
function checkCollision(box1::Rectangle, box2::Rectangle)
    return (
        box1.x < box2.x + box2.w &&
        box1.x + box1.w > box2.x &&
        box1.y < box2.y + box2.h &&
        box1.y + box1.h > box2.y
    )
end