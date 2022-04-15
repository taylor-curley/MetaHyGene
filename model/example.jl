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
#Random.seed!(8197)
###############################################################################################
#                                         Example Data                                        #
###############################################################################################
ex_params = (n_subs = 1, n_features = 10, n_trials = 400, relatedness = 0.25, decay = 0.65)
ex_model = MHG(;ex_params...)
ex_outcome = cued_recall(ex_model, 0.5)
ex_corr = sum(ex_outcome.Outcome .== :Correct)
ex_comm = sum(ex_outcome.Outcome .== :Comm)
ex_omm = sum(ex_outcome.Outcome .== :Omm)
ex_echo = ex_outcome.EchoInt
# define observed data
data = (;n_trials=ex_params.n_trials, outcomes=[ex_corr,ex_comm,ex_omm],ex_echo)
###############################################################################################
#                                     Estimate Parameters                                     #
###############################################################################################
# ρ = relatedness; κ = decay

# if the posterior is difficult to sample, try a probit transformation
function prior_loglike(ρ, κ)
    LL = 0.0
    LL += logpdf(Beta(2, 8), ρ)
    LL += logpdf(Beta(6, 4), κ)
    return LL
end

# function for initial values
function sample_prior()
    ρ = rand(Beta(2, 8))
    κ = rand(Beta(6, 4))
    return [ρ,κ]
end

# likelihood function 
function loglike(data, ρ, κ; sim_params...)
    sim_model = MHG(;sim_params..., relatedness = ρ, decay = κ)
    sim_dat = cued_recall(sim_model, 0.5)
    outcomes = [:Correct,:Comm,:Omm]
    # I'm not sure in what ways you plan to use the data. if Outcomes 
    # the same three categories, and trials are from the same distribution 
    # you could increment the outcome counters and return those instead of 
    # computing the sums below. 
    n_outcomes = map(o -> sum(sim_dat.Outcome .== o), outcomes)
    θ = n_outcomes / sim_model.n_trials
    ll = logpdf(Multinomial(data.n_trials, θ), data.outcomes)
    return ll
end

###############################################################################################
#                                       Configure DEMCMC                                      #
###############################################################################################
# parameter names
names = (:ρ,:κ)
# parameter bounds
bounds = ((0.0,1,0),(0.0,1.0))
# parameters of simulation 
sim_params = (n_subs = 1, n_features = 10, n_trials = 500)

# model object
model = DEModel(; 
    sample_prior, 
    prior_loglike, 
    loglike, 
    data,
    names,
    sim_params...
)

# DEMCMC sampler object
de = DE(;sample_prior, bounds, burnin = 500, Np = 6)
# number of interations per particle
n_iter = 1000

chains = sample(model, de, MCMCThreads(), n_iter, progress=true)

savefig(plot(chains), "../etc/ex_mhg.pdf")
# So far, the DEMCMC procedure does not seem to yield results that are sensitive to the true parameters.