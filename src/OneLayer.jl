module OneLayer

import Convex: Variable, Constraint, AbstractExpr

# Write your package code here.
abstract type Protocol end
export 
DAI, 
AAVE,
Asset,
# Aave,
# swap,
# RateModel,
# StableRate, 
# VariableRate,
# User,
# AaveDebt,
aDAI,
aAAVE,
aToken
# Debt





include("currencies.jl")
include("swap.jl")
include("solver.jl")
include("cpmm.jl")
# include("user.jl")
# include("aave.jl")
println("What?!")
end
