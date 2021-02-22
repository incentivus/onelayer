module OneLayer

# Write your package code here.

export DAI
export ETH
export Asset
export Aave
export swap
export RateModel
export StableRate, VariableRate
export User

abstract type Protocol end

include("currencies.jl")
include("user.jl")
include("aave.jl")


end
