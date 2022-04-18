module MetaHyGene

    using Distributions, DataFrames, StatsBase, ConcreteStructs, Random

    export cued_recall, recall_trial, recognition
    include("main.jl")

    export sim_controller, sim_replicator, trace_replicator, sim_calc, act_calc, echo_intensity, echo_content, recall_summary, block_header, line_header
    include("utils.jl")

    export AbstractMHG, MHG, Memory
    include("structs.jl")

end
