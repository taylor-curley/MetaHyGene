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
params = (n_subs = 50, n_trials = 60, n_features = 20, relatedness = 0.0, decay = 0.5, threshold = 0.2, kmax = 20)
recall_data = cued_recall(;params...)
corr_mean, corr_std = mean(recall_data.Accuracy), std(recall_data.Accuracy)
comm_mean, comm_std = mean(recall_data.Outcome.==:Commission), std(recall_data.Outcome.==:Commission)
omm_mean, omm_std = mean(recall_data.Outcome.==:Omission), std(recall_data.Outcome.==:Omission)