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
#                                     Vanilla Cued Recall                                     #
###############################################################################################
params = (n_subs = 100, n_trials = 60, n_features = 20, relatedness = 0.0, decay = 0.5, threshold = 0.2, kmax = 20)
recall_data = cued_recall(;params...)
corr_mean, corr_std = mean(recall_data.Accuracy), std(recall_data.Accuracy)
comm_mean, comm_std = mean(recall_data.Outcome.==:Commission), std(recall_data.Outcome.==:Commission)
omm_mean, omm_std = mean(recall_data.Outcome.==:Omission), std(recall_data.Outcome.==:Omission)
###############################################################################################
#                                      Parameter Recovery                                     #
###############################################################################################
function prior_loglike(δ, τ)
    ll = logpdf(Beta(1,1), δ)
    ll += logpdf(Beta(1,1), τ)
    return ll
end

function sample_prior()
    δ = rand(Beta(1,1)) 
    τ = rand(Beta(1,1))
    return [δ,τ]
end

bounds  = ((0.0,1.0),(0.0,1.0))
names = (:δ, :τ)
data = [corr_mean,comm_mean,omm_mean]

function loglike(data, δ, τ)
    n_s = 10; n_t = 60
    sim_dat = cued_recall(;n_subs = n_s, n_trials = n_t, n_features = 20, 
                          relatedness = 0.0, decay = δ, 
                          threshold = τ, kmax = 20)
    corrs = sum(sim_dat.Outcome.==:Correct)
    comms = sum(sim_dat.Outcome.==:Commision)
    oms = sum(sim_dat.Outcome.==:Omission)
    ll = logpdf(Binomial(n_s*n_t,data[1]),corrs)
    ll += logpdf(Binomial(n_s*n_t,data[2]),comms)
    ll += logpdf(Binomial(n_s*n_t,data[3]), oms)
    return ll
end

model = DEModel(; 
    sample_prior, 
    prior_loglike, 
    loglike, 
    data,
    names
)

de = DE(;sample_prior, bounds, burnin = 2_000, Np = 6)

n_iter = 4_000

chains = sample(model, de, MCMCThreads(), n_iter, progress=true)

if savefig
    Plots.savefig(plot(chains), "../etc/ex_mhg_recall.pdf")
end
# Parameters successfully recovered