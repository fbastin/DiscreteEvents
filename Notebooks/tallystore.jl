#TODO: learn about abstract types in Julia to make tallystore inherits from tally

#include("tally.jl")

type TallyStore

    obs
    t:: Tally

    function TallyStore(text:: String)
        ts = new()
        ts.t = Tally(text)
        ts.obs = Float64[]
        return ts
     end

end

function add(ts::TallyStore, x::Float64)
    add(ts.t, x)
    push!(ts.obs, x)
end     
