using Distributions

function ci_normal(n::Int64, mean::Float64, stdev::Float64, α::Float64)
    z = quantile(Normal(), 1-α/2)
    w = z*stdev/sqrt(n)
    # Lower bound
    l = mean - w
    # Upper bound
    u = mean + w
    
    return l, u
end

function ci_tdist(n::Int64, mean::Float64, stdev::Float64, α::Float64)
    z = quantile(TDist(n-1), 1-α/2)
    w = z*stdev/sqrt(n)
    # Lower bound
    l = mean - w
    # Upper bound
    u = mean + w
    
    return l, u
end
