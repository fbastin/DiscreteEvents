using SimJulia
using Distributions
using RandomStreams
using Distributions

const SEED = 12345

rand_dist(rng::MRG32k3a, Dist::Distribution) = quantile(Dist, rand(rng))

seeds = [SEED, SEED, SEED, SEED, SEED, SEED]
gen = MRG32k3aGen(seeds)

include("ci.jl")
include("tally.jl")
include("tallystore.jl")

#rates
λ = 1.9
μ = 2.0
ρ = λ/μ

type System
    W
    arrival
    service
    counter
    arrgen
    servgen

    threshold::Float64
    SL::Int

    function System(text::String)
        s = new()
        s.W = Tally(text)
        s.arrival = Exponential(1.0/λ)
        s.service = Exponential(1.0/μ)
        s.arrgen = next_stream(gen)
        s.servgen = next_stream(gen)
	s.threshold = Inf
	s.SL = 0
        return s;
    end
end

function restart(s::System)
    init(s.W)
    s.SL = 0
    next_substream!(s.arrgen)
    next_substream!(s.servgen)
end

function reset(s::System)
    init(s.W)
    s.SL = 0
    reset_stream!(s.arrgen)
    reset_stream!(s.servgen)
end

function system_set_arrival(s::System, rate::Float64)
    s.arrival = Exponential(1.0/rate)
end

function system_set_service(s::System, rate::Float64)
    s.service = Exponential(1.0/rate)
end

function system_set_threshold(s::System, threshold::Float64)
    s.threshold = threshold
end

s = System("Waiting Times")

# Allow a simulation with a fixed number of clients
function source(env::Environment, s::System, limit::Float64)
    i = 0
    while (true)
        yield(Timeout(env, rand_dist(s.arrgen, s.arrival)))
        if (now(env) > limit) break end
        i += 1
        Process(env, customer, s, i)
    end
end

function source(env::Environment, s::System, nCusts::Int64)
    for i = 1:nCusts
        yield(Timeout(env, rand_dist(s.arrgen, s.arrival)))
        Process(env, customer, s, i)
    end
end

function customer(env::Environment, s::System, idx::Int)
    # Record the arrival time in the system
    arrive = now(env)
    yield(Request(s.counter))
    # The simulation clock now contains the time when the client goes to the server.
    wait = now(env) - arrive
    # Record the waiting time
    add(s.W, wait)
    if (wait <= s.threshold)
        s.SL += 1
    end
    yield(Timeout(env, rand_dist(s.servgen, s.service)))
    yield(Release(s.counter))
end

function queue(s::System, nCustomers::Int)
    env = Environment()
    s.counter = Resource(env, 1)
    
    Process(env, source, s, nCustomers)
    run(env)
end

function queue(s::System, horizon::Float64)
    env = Environment()
    s.counter = Resource(env, 1)
    
    Process(env, source, s, horizon)
    run(env)
end
