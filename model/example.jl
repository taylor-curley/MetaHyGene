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
ex_echo = ex_outcome.EchoInt

###############################################################################################
#                                     Estimate Parameters                                     #
###############################################################################################
# ρ = relatedness; κ = decay

function prior_loglike(ρ, κ)
    LL = 0.0
    LL += logpdf(truncated(Normal(0.5, 0.5), 0.0, Inf), ρ)
    LL += logpdf(truncated(Normal(0.5, 0.5), 0.0, Inf), κ)
    return LL
end

# function for initial values
function sample_prior()
    ρ = rand(truncated(Normal(0.5, 0.5), 0.0, Inf))
    κ = rand(truncated(Normal(0.5, 0.5), 0.0, Inf))
    return [ρ,κ]
end

# likelihood function 
function loglike(data, ρ, κ; sim_params...)
    sim_model = MHG(;sim_params..., relatedness = ρ, decay = κ)
    sim_dat = cued_recall(sim_model, 0.5)
    outcomes = [:Correct,:Comm,:Omm]
    n_outcomes = map(o -> sum(sim_dat.Outcome .== o), outcomes)

    # echo_pararms = fit(Normal, data[4])
    # for i in 1:length(data[4])
    #     ll += logpdf(echo_params,data[4][i])
    # end
    θ = data.outcomes / sim_model.n_trials
    ll = logpdf(Multinomial(sim_model.n_trials, θ), n_outcomes)
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
data = (;outcomes=[ex_corr,ex_comm,ex_omm],ex_echo)
# parameters of simulation 
sim_params = (n_subs = 1, n_features = 10, n_trials = 40)


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
de = DE(;sample_prior, bounds, burnin = 2_000, Np = 6)
# number of interations per particle
n_iter = 6_000

chains = sample(model, de, MCMCThreads(), n_iter, progress=true)

savefig(plot(chains), "../etc/ex_mhg.pdf")
# So far, the DEMCMC procedure does not seem to yield results that are sensitive to the true parameters.