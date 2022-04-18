# Retiring the MHG structure for now. Will need to construct a separate memory structure (TC)
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
"""
@concrete mutable struct MHG <: AbstractMHG
    n_subs
    n_features
    n_trials
    relatedness
    decay
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

    return MHG(n_subs, n_features, n_trials, relatedness, decay)
end
