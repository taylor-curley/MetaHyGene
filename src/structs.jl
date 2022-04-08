abstract type AbstractMHG end

@concrete mutable struct MHG{Int64,Float64,Matrix} <: AbstractMHG
    n_subs::Int64
    n_features::Int64
    n_trials::Int64
    relatedness::Float64
    decay::Float64
    cues::Matrix
    targets::Matrix
end

function MHG(;
    n_subs::Int64,
    n_features::Int64,
    n_trials::Int64,
    relatedness::Float64,
    decay::Float64)

    cues, targets = sim_controller(n_features, n_trials, relatedness)
    cues = trace_replicator(cues, decay)
    targets = trace_replicator(targets, decay)
    for s in 2:n_subs
        _cues, _targets = sim_controller(n_features, n_trials, relatedness)
        cues = vcat(cues,_cues); targets = vcat(targets,_targets)
    end

    return MHG(n_subs, n_features, n_trials, relatedness, decay, cues, targets)
end
