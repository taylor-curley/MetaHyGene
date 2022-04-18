abstract type AbstractMHG end

"""
    MHG <: AbstractMHG

An object representing a MetaHyGene model.

# Fields 

- `n_subs`: the number of subjects in the simulation 
- `n_features`: the number of features in a memory trace 
- `n_trials`: the number of trials in the simulated experiment 
- `relatedness`: the degree of relatedness between memory traces 
- `decay`: decay in memory activation 
- `cues`: a vector of cues, one for each trial 
- `targets`: a vector of targets, one for each trial 
"""
@concrete mutable struct MHG <: AbstractMHG
    n_subs
    n_features
    n_trials
    relatedness
    decay
    cues
    targets
end

"""
    MHG(;
        n_subs::Int64,
        n_features::Int64,
        n_trials::Int64,
        relatedness::Float64,
        decay::Float64
    )

An constructor for a MetaHyGene model which generates cues and targets. 

# Keywords 

- `n_subs`: the number of subjects in the simulation 
- `n_features`: the number of features in a memory trace 
- `n_trials`: the number of trials in the simulated experiment 
- `relatedness`: the degree of relatedness between memory traces 
- `decay`: decay in memory activation 
"""
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
