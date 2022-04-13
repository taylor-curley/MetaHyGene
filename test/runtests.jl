using SafeTestsets

@safetestset "model constructor" begin
    using MetaHyGene
    using Test
    ex_params = (n_subs = 1, n_features = 10, n_trials = 40, relatedness = 0.25, decay = 0.65)
    model = MHG(;ex_params...)

    @test model.n_subs == ex_params.n_subs
    @test size(model.cues) == (model.n_trials,model.n_features)
    @test size(model.targets) == (model.n_trials,model.n_features)
end
