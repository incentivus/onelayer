abstract type Currency end

struct Asset{C}
    balance::Number
    function Asset{C}(a::Number) where C <: Currency
        C()
        new{C}(a)
    end
end


struct RegularCurrency{S} <: Currency
    function RegularCurrency{S}() where {S}
        haskey(_regular_data, S) || error("Regular currency $S is not defined.")
        new{S}()
    end
end

const _regular_data = Dict(
	:DAI  => (RegularCurrency{:DAI},  18),
	:AAVE => (RegularCurrency{:AAVE}, 18))

struct aToken{S, P} <: Currency
    function aToken{S, P}() where {S, P}
        haskey(_atoken_data, S) || error("aToken $S is not defined.")
        new{S, P}()
    end
end

const _atoken_data = Dict(
	:aDAI  => (aToken{:DAI},  :DAI, RegularCurrency{:DAI}),
	:aAAVE => (aToken{:AAVE}, :AAVE, RegularCurrency{:AAVE}))

import Base.+, Base.*, Base.-, Base./

*(a::Number, b::Asset{T}) where {T} = Asset{T}(a*b.balance)
+(a::Asset{T}, b::Asset{T}) where {T} = Asset{T}(a.balance+b.balance)

Asset{T}() where {T} = Asset{T}(1)

DAI = Asset{RegularCurrency{:DAI}}()


println(10DAI)



for k in keys(_regular_data)
    Meta.parse("$k = Asset{RegularCurrency{:$k}}()") |> eval
end

for x in keys(_atoken_data)
    Meta.parse("$x = Asset{aToken{:$x, _atoken_data[:$x][2] }}()") |> eval
end


+(a::Asset{RegularCurrency{S}}, b::Asset{aToken{P, S}}) where {S, P} =  Asset{RegularCurrency{S}}(a.balance+b.balance)

swap(a::Asset{RegularCurrency{S}}, ::Type{Asset{aToken{P, S}}}) where {S, P} =  Asset{aToken{P, S}}(a.balance)


