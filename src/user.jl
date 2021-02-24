abstract type Debt end


struct User
    assets::Dict{String, Asset}
    debts::Array{Debt, 1}
    User() = new(Dict(), [])
end

import Base: +, -
function +(u::User, a::Asset)
    if haskey(u.assets, a.symbol)
        u.assets[a.symbol] = u.assets[a.symbol] + a
    else 
        u.assets[a.symbol] = a
    end
end 

function -(u::User, a::Asset)
    if haskey(u.assets, a.symbol)
        u.assets[a.symbol] = u.assets[a.symbol] - a
    end
end 
