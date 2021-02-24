abstract type aToken <: Asset end

struct Pool
    asset::Asset
    marketSize::Int128
    totalBorrowed::Int128
    depositAPY::Float64
    variableBorrowAPR::Float64
    stableBorrowAPR::Float64
end

struct aDAI <: aToken
    underlyingAsset::DAI
    function aDAI(value::Number)
        new(DAI(value))
    end
end

struct aETH <: aToken
    underlyingAsset::ETH
    function aETH(value::Number)
        new(ETH(value))
    end
end


import Base: +, -, *

function +(a1::T, a2::T) where T <: aToken
    T(a1.underlyingAsset.value + a2.underlyingAsset.value)
end

function -(a1::T, a2::T) where T <: aToken
    T(a1.underlyingAsset.value - a2.underlyingAsset.value)
end

function *(a::T, m::Number) where T <: aToken
    T(a.underlyingAsset.value*m)
end

function *(m::Number, a::T) where T <: aToken
    T(a.underlyingAsset.value*m)
end


struct AaveDebt <: Debt
    borrowedAssets::Array{Asset, 1}
end

struct Aave <: Protocol
    pools::Array{Pool,1}
    function Aave()
        println("New aave created")
        p1 = Pool(ETH(0), 100, 20, 10.2, 50.4, 40.3)
        new([p1])
    end
end

abstract type RateModel end
abstract type StableRate <: RateModel end
abstract type VariableRate <: RateModel end


function updatePool!(proto::Aave, pool::Pool) end


function swap(proto::Aave, src::aToken, dst::Type{T}, user::User) where T <: aToken end

function swap(proto::Aave, src::Array{Asset, 1}, dst::Type{Asset}, ::Type{RateModel}, user::User) end

function swap(proto::Aave, src::DAI, dst::Type{T}, ::Type{StableRate}, user::User) where T <: Asset end

function swap(proto::Aave, src::DAI, dst::Type{T}, ::Type{VariableRate}, user::User) where T <: Asset end






