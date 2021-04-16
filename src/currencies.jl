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

symbol(a::Asset{C}) = symbol(C)
symbol(Type{RegularCurrency{T}}) where {T} = T

unify(a::Asset{T}) where {T} = Asset{T}(1)
balance(a::Asset{T}) where {T} = a.balance

# TODO add support for rounding upto precision/decimal of each currency


import Base.+, Base.*, Base.-, Base./

*(a::Number, b::Asset{T}) where {T} = Asset{T}(a*b.balance)
*(a::Asset{T}, b::Number) where {T} = Asset{T}(b*a.balance)
/(a::Asset{T}, b::Number) where {T} = Asset{T}(a.balance/b)
+(a::Asset{T}, b::Asset{T}) where {T} = Asset{T}(a.balance+b.balance)

Asset{T}() where {T} = Asset{T}(1)


for k in keys(_regular_data)
    Meta.parse("$k = Asset{RegularCurrency{:$k}}()") |> eval
end



