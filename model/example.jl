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
# Do not save figures by default
savefig = false    
###############################################################################################
#                                         Example Data                                        #
###############################################################################################
# Sample yes/no recognition. 100 participants, 100 trials, 20 features, 0.25 decay, 0.25 threshold
ex_data = recognition(100, 20, 100, 0.25, 0.25)
# Extract HR and far
ex_hr = sum(ex_data.RESP[ex_data.Target_Present.==1])./((100*100)/2)
ex_far = sum(ex_data.RESP[ex_data.Target_Present.==0])./((100*100)/2)

###############################################################################################
#                                     Estimate Parameters                                     #
###############################################################################################
# κ = decay; τ = threshold

function prior_loglike(κ,τ)
    LL = 0.0
    LL += logpdf(Beta(2, 8), κ)
    LL += logpdf(Beta(2, 8), τ)
    return LL
end

# function for initial values
function sample_prior()
    κ = rand(Beta(2, 8))
    τ = rand(Beta(2, 8))
    return [κ,τ]
end

# likelihood function 
function loglike(data, κ, τ)
    sim_dat = recognition(1, 20, 100, κ, τ)
    sim_hits = sum(sim_dat.RESP[sim_dat.Target_Present.==1])
    sim_fas = sum(sim_dat.RESP[sim_dat.Target_Present.==0])
    ll = logpdf(Binomial((100*0.5),data[1]),sim_hits)
    ll += logpdf(Binomial((100*0.5),data[2]),sim_fas)
    return ll
end

###############################################################################################
#                                       Configure DEMCMC                                      #
###############################################################################################
# parameter names
names = (:κ,:τ)
# parameter bounds
bounds = ((0.0,1,0),(0.0,1.0))
# Input data
data = [ex_hr,ex_far]

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
n_iter = 4_000

chains = sample(model, de, MCMCThreads(), n_iter, progress=true)

if savefig
    savefig(plot(chains), "../etc/ex_mhg.pdf")
end
# Parameters successfully recovered