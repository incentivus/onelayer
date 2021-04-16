module OneLayer

# Write your package code here.

export 
DAI, 
ETH,
Asset,
Aave,
swap,
RateModel,
StableRate, 
VariableRate,
User,
AaveDebt,
aDAI,
aETH,
aToken,
Debt





include("currencies.jl")
include("user.jl")
include("aave.jl")
println("What?!")
end
