mutable struct Swap
    assets::Array{Asset, 1}
    variable::Union{Variable, Nothing}
    private_data::Any
end

Swap() = Swap([], nothing, nothing)

addAsset!(s::Swap, asset::Asset) = push!(s.assets, asset)
addAssets!(s::Swap, assets::Array{Asset, 1}) = append!(s.assets, assets)
assets(s::Swap) = s.assets

function setPrivateData!(s::Swap, data::Any)
    s.private_data = data
end

function setVariable!(s::Swap, v::Variable)
    s.variable = v
end
