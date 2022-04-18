module MetaHyGene

    using Distributions, DataFrames, StatsBase, ConcreteStructs, Random

    export recognition
    include("main.jl")

    export sim_controller, trace_replicator, sim_calc, act_calc, echo_intensity, echo_content, block_header, line_header
    include("utils.jl")

    export AbstractMHG, MHG
    include("structs.jl")

end
