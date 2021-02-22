struct Pool
    asset::Asset
    marketSize::Int128
    totalBorrowed::Int128
    depositAPY::Float64
    variableBorrowAPR::Float64
    stableBorrowAPR::Float64
end

struct Aave <: Protocol
    pools::Array{Pool,1}
    function Aave()
        p1 = Pool(ETH(0), 100, 20, 10.2, 50.4, 40.3)
        new([p1])
    end
end

abstract type RateModel end
abstract type StableRate <: RateModel end
abstract type VariableRate <: RateModel end

function swap(proto::Aave, src::Array{Asset, 1}, dst::Type{Asset}, ::Type{RateModel}, user::User) end

function swap(proto::Aave, src::DAI, dst::Type{T}, ::Type{StableRate}, user::User) where T <: Asset end

function swap(proto::Aave, src::DAI, dst::Type{T}, ::Type{VariableRate}, user::User) where T <: Asset end
