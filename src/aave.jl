# abstract type aToken <: Asset end
# Test


struct aToken{S, P} <: Currency
    function aToken{S, P}() where {S, P}
        haskey(_atoken_data, S) || error("aToken $S is not defined.")
        new{S, P}()
    end
end

const _atoken_data = Dict(
        :aDAI  => (aToken{:DAI},  :DAI, RegularCurrency{:DAI}),
        :aAAVE => (aToken{:AAVE}, :AAVE, RegularCurrency{:AAVE}))

for x in keys(_atoken_data)
    Meta.parse("$x = Asset{aToken{:$x, _atoken_data[:$x][2] }}()") |> eval
end

struct Pool{USDT}
    asset::Asset
    marketSize::Int128
    totalBorrowed::Int128
    depositAPY::Float64
    variableBorrowAPR::Float64
    stableBorrowAPR::Float64
end

# depositAPY(::Type{Pool{T}})

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


swap(a::Asset{RegularCurrency{S}}, ::Type{Asset{aToken{P, S}}}) where {S, P} =  Asset{aToken{P, S}}(a.balance)



