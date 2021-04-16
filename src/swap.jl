mutable struct Swap
    assets::Array{Asset, 1}
    variables::Array{Variable, 1}
    private_data::Any
end

Swap() = Swap([], nothing, nothing)
Swap(assets::Array{Asset, 1}, prv::Any) = Swap(assets, nothing, prv)
Swap(asset::Asset, prv::Any) = Swap([asset], nothing, prv)
Swap(assets::Array{Asset, 1}) = Swap(assets, nothing, nothing)
Swap(asset::Asset) = Swap([asset], nothing, nothing)

addAsset!(s::Swap, asset::Asset) = push!(s.assets, asset)
addAssets!(s::Swap, assets::Array{Asset, 1}) = append!(s.assets, assets)
assets(s::Swap) = s.assets

function setPrivateData!(s::Swap, data::Any)
    s.private_data = data
end

function addVariable!(s::Swap, v::Variable)
    push!(s.variables, v)
end
