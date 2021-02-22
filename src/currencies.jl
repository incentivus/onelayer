import Base: +, -, *

abstract type Asset end
function +(a1::Asset, a2::Asset) 
    throw(DomainError(typeof(a2), "Argument types missmatch: $(typeof(a1)) + $(typeof(a2))"))
end
function -(a1::Asset, a2::Asset) 
    throw(DomainError(typeof(a2), "Argument types missmatch: $(typeof(a1)) + $(typeof(a2))"))
end
function *(a::T, m::Int64) where T <: Asset
    T(a.value*m)
end
function *(m::Int64, a::T) where T <: Asset
    T(a.value*m)
end
struct DAI <: Asset
    symbol::String
    precision::Int64
    value::Int64
    DAI(v::Int64) = new("DAI", 0, v)
end

struct ETH <: Asset
    symbol::String
    precision::Int64
    value::Int64
    ETH(v::Int64) = new("ETH", 0, v)
end

function +(a1::T, a2::T) where T <: Asset 
     T(a1.value + a2.value)
end

function -(a1::T, a2::T) where T <: Asset
     T(a1.value + a2.value)
end

# 
# a1 = DAI(10)
# a2 = DAI(30)
# 
# e1 = ETH(10)
# println(a1+e1)

