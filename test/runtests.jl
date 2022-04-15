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

@safetestset "sim_replicator" begin
    using MetaHyGene
    using Test, Random, Statistics 
    Random.seed!(845)

    probe = fill(0, 500, 500)
    p = .4
    x = sim_replicator(probe, p)
    # expected probability an element is zero
    p_zero = p + (1 - p) * .2
    est_p_zero = mean(x .== 0)
    @test p_zero ≈ est_p_zero atol = 1e-3
    est_p_one = mean(x .== 1)
    @test (1 - p_zero) / 2 ≈ est_p_one atol = 1e-3
    est_p_neg_one = mean(x .== -1)
    @test (1 - p_zero) / 2 ≈ est_p_neg_one atol = 1e-3


    p = .1
    x = sim_replicator(probe, p)
    # expected probability an element is zero
    p_zero = p + (1 - p) * .2
    est_p_zero = mean(x .== 0)
    @test p_zero ≈ est_p_zero atol = 1e-3
    est_p_one = mean(x .== 1)
    @test (1 - p_zero) / 2 ≈ est_p_one atol = 1e-3
    est_p_neg_one = mean(x .== -1)
    @test (1 - p_zero) / 2 ≈ est_p_neg_one atol = 1e-3

    p = .9
    x = sim_replicator(probe, p)
    # expected probability an element is zero
    p_zero = p + (1 - p) * .2
    est_p_zero = mean(x .== 0)
    @test p_zero ≈ est_p_zero atol = 1e-3
    est_p_one = mean(x .== 1)
    @test (1 - p_zero) / 2 ≈ est_p_one atol = 1e-3
    est_p_neg_one = mean(x .== -1)
    @test (1 - p_zero) / 2 ≈ est_p_neg_one atol = 1e-3
end

