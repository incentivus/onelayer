module OneLayer

import Convex: Variable, Constraint, AbstractExpr, maximize
import Convex
using PyCall

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



pushfirst!(PyVector(pyimport("sys")["path"]), "")

include("currencies.jl")
include("swap.jl")
include("solver.jl")
include("cpmm.jl")
# include("user.jl")
# include("aave.jl")
println("How?!")
end
