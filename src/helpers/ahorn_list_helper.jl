getTreeData(m::Nothing, simple::Bool=false) = Tuple{String, Int, Int, Int, Int}[]
function getTreeData(m::Maple.Map, simple::Bool=get(config, "use_simple_room_values", true))
    data = Tuple{String, Int, Int, Int, Int}[]

    for room in m.rooms
        if simple
            push!(data, (room.name, round.(Int, room.position ./ 8)..., round.(Int, room.size ./ 8)...))

        else
            push!(data, (room.name, room.position..., room.size...))
        end
    end

    return data
end