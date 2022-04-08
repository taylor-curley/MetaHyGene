###############################################################################################
#                                       Import Packages                                       #
###############################################################################################
# use directory containing this file
cd(@__DIR__)
using Pkg 
# use package environment
Pkg.activate("..")
using MetaHyGene, Random, Distributions, Plots, StatsPlots, StatsBase, DataFrames
using DifferentialEvolutionMCMC


###############################################################################################
#                                         Example Data                                        #
###############################################################################################
ex_params = (n_subs = 1, n_features = 10, n_trials = 40, relatedness = 0.25, decay = 0.65)
ex_model = MHG(;ex_params...)
ex_outcome = cued_recall(ex_model, 0.5)
ex_corr = sum(ex_outcome.Outcome .== :Correct)
ex_comm = sum(ex_outcome.Outcome .== :Comm)
ex_omm = sum(ex_outcome.Outcome .== :Omm)


###############################################################################################
#                                     Estimate Parameters                                     #
###############################################################################################
# ρ = relatedness; κ = decay

function prior_loglike(ρ, κ)
    LL = 0.0
    LL += logpdf(truncated(Normal(0.5, 0.25), 0.0, 1.0), ρ)
    LL += logpdf(truncated(Normal(0.5, 0.25), 0.0, 1.0), κ)
    return LL
end

# function for initial values
function sample_prior()
    ρ = rand(truncated(Normal(0.5, 0.25), 0.0, 1.0))
    κ = rand(truncated(Normal(0.5, 0.25), 0.0, 1.0))
    return [ρ,κ]
end

# likelihood function 
function loglike(data, ρ, κ)
    sim_params = (n_subs = 1, n_features = 10, n_trials = 40, relatedness = ρ, decay = κ)
    sim_model = MHG(;sim_params...)
    sim_dat = cued_recall(sim_model, 0.5)
    corr = sum(sim_dat.Outcome .== :Correct)
    comm = sum(sim_dat.Outcome .== :Comm)
    omm = sum(sim_dat.Outcome .== :Omm)
    ll = 0.0
    ll += logpdf(Binomial(sim_model.n_trials, data[1]/sim_model.n_trials), corr)
    ll += logpdf(Binomial(sim_model.n_trials, data[2]/sim_model.n_trials), comm)
    ll += logpdf(Binomial(sim_model.n_trials, data[3]/sim_model.n_trials), omm)
    return ll
end

###############################################################################################
#                                       Configure DEMCMC                                      #
###############################################################################################

# parameter names
names = (:ρ,:κ)
# parameter bounds
bounds = ((0.0,1,0),(0.0,1.0))
# define observed data
data = [ex_corr,ex_comm,ex_omm]

# model object
model = DEModel(; 
    sample_prior, 
    prior_loglike, 
    loglike, 
    data,
    names
)

# DEMCMC sampler object
de = DE(;sample_prior, bounds, burnin = 2_000, Np = 6)
# number of interations per particle
n_iter = 6_000

chains = sample(model, de, MCMCThreads(), n_iter, progress=true)

