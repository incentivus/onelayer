include("currencies.jl")
include("aave.jl")

using .Currencies
using .AaveProto

e1 = ETH(10)
e2 = ETH(20)
ee3 = ETH(30)
println(ee3*10, 10ee3)
println(e1+e2+ee3)

aave = Aave()
swap(aave, DAI(10), ETH, StableRate)
