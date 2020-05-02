function drawFiller(ctx::Cairo.CairoContext, camera::Camera, filler::Filler; alpha::Number=getGlobalAlpha())
    if ctx.ptr != C_NULL
        x, y = Int(filler.x) * 8, Int(filler.y) * 8
        w, h = Int(filler.w) * 8, Int(filler.h) * 8

        Cairo.save(ctx)
        
        translate(ctx, -camera.x, -camera.y)
        scale(ctx, camera.scale, camera.scale)
        translate(ctx, x, y)

        Ahorn.drawRectangle(ctx, 0, 0, w, h, colors.filler_room_fill)

        Cairo.restore(ctx)
    end
end

function fillerVisible(camera::Camera, width::Integer, height::Integer, filler::Filler)
    actuallX = camera.x / camera.scale
    actuallY = camera.y / camera.scale

    actuallWidth = width / camera.scale
    actuallHeight = height / camera.scale

    x, y = Int(filler.x) * 8, Int(filler.y) * 8
    w, h = Int(filler.w) * 8, Int(filler.h) * 8

    cameraRect = Rectangle(actuallX, actuallY, actuallWidth, actuallHeight)
    fillerRect = Rectangle(x, y, w, h)

    return checkCollision(cameraRect, fillerRect)
end