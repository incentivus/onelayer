struct Pool
    collateral::Asset #should be Array{Asset, 1} if MCD
	debtCeiling::DAI
	dustLimit::DAI
	liquidityTHR::Float64 #should be Dict{Asset, Float} if MCD
	stabilityFeeRate::Float64 #should be Dict{Asset, Float} if MCD
	liquidationPenalty::float
	# there were other parameters like auction duration that are considered unimportant in modeling
end

struct MKRDebt <: Debt
	collateral::Asset
	daiMinted::DAI
	pool::Pool
end

struct Maker <: Protocol
    pools::Array{Pool,1}
    function Maker()
        p1 = Pool(ETH(0), 10, 100, 20, 1.2, 0.04, 0, 0, 1, 0.01)
        new([p1])
    end
end

function collaterallize(u::User, a::Asset)
	if haskey(u.vaults, a.symbol)
        u.vaults[a.symbol] = u.vaults[a.symbol] + a
    else 
        u.vaults[a.symbol] = a
    end
end

function swap(proto::Maker, src::Asset, dst::Type{DAI}, user::User) end #this swap is a borrow

function swap(proto::Maker, src::DAI, dst::Type{Asset}, user::User) end #this swap is a pay-back, Debt Auction, or Collateral Auction

##function swap(proto::Maker, src::DAI, dst::Maker, user::User) end #this swap is a Debt Auction

##function swap(proto::Maker, src::DAI, dst::Asset, user::User) end #this swap is a Collateral Auction

