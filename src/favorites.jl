function getFavorites(config::Config, key::String)
    favorites = get(config, key, Array{String, 1}())
    config[key] = favorites

    return favorites
end

function addFavorite(config::Config, favoritesKey::String, favorite::String, favorites::Array{T, 1}=getFavorites(config, favoritesKey)) where T
    if !(favorite in favorites)
        push!(favorites, favorite)
    end
end

function removeFavorite(config::Config, favoritesKey::String, favorite::String, favorites::Array{T, 1}=getFavorites(config, favoritesKey)) where T
    filter!(f -> f != favorite, favorites)
end

function toggleFavorite(config::Config, favoritesKey::String, favorite::String)
    favorites = getFavorites(config, favoritesKey)

    if favorite in favorites
        removeFavorite(config, favoritesKey, favorite, favorites)

    else
        addFavorite(config, favoritesKey, favorite, favorites)
    end
end