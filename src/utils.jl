"""
    sim_controller()

Creates vectors of integers [-1,0,1] with probability [0.4,0.2,0.4].

# Parameters
  - `n_features::Int64`: The number of features (columns).
  - `n_trials::Int64`: The number of stimuli (rows).
  - `relatedness::Float64`: Probability of replacing current integer with random choice from [-1,0,1].

"""
sim_controller(n_features::Int64) = sample([-1,0,1], Weights([0.4,0.2,0.4]), n_features)

sim_controller(n_features::Int64, n_trials::Int64) = sample([-1,0,1], Weights([0.4,0.2,0.4]), (n_trials,n_features))

function sim_controller(n_features::Int64, relatedness::Float64)
    a = sample([-1,0,1], Weights([0.4,0.2,0.4]), n_features)
    b = sim_replicator(a, relatedness)
    return a,b
end

function sim_controller(n_features::Int64, n_trials::Int64, relatedness::Float64)
    a = sample([-1,0,1], Weights([0.4,0.2,0.4]), (n_trials,n_features))
    b = sim_replicator(a, relatedness)
    return a,b
end


"""
    trace_replicator()

Replaces integers in probe array with 0 with probability `decay`.

# Parameters
  - `probe`: Vector to be replicated.
  - `decay::Float64`: Rate of decay between 0.0 and 1.0, with 1.0 being complete decay.

"""
function trace_replicator(probe, decay::Float64)
    out_vec = copy(probe)
    for i in 1:length(probe)
        rand() < decay ? out_vec[i] = 0 : nothing
    end
    return out_vec
end

"""
    sim_calc()

Calculates the similarity between two probes, or against a probe and a matrix or item vectors.
Basically the dot product divided by the number of features, excluding "shared" features.

# Parameters
  - `probe`: Vector of integers representing a single item.
  - `referent`: Vector or matrix of integers to which the probe is compared.

"""
function sim_calc(probe::Vector, referent::Vector)
    base = 0.0; count = length(probe)
    for i in 1:length(probe)
        (probe[i] == 0) && (referent[i] == 0) ? count -= 1 : base += (probe[i] * referent[i])
    end
    return base/count
end

function sim_calc(probe::Vector, referent::Matrix)
    n = size(referent, 1)
    sims = fill(0.0, n)
    for i in 1:n
        sims[i] = sim_calc(probe, @view referent[i,:])
    end
    return sims
end


"""
    act_calc()

Hintzman's (1984) "activation" value. Vector similarity (`sim_calc`) to the third power.

# Parameters
  - `probe`: Vector of integers representing a single item.
  - `referent`: Vector or matrix of integers to which the probe is compared.

"""
act_calc(probe::Vector, referent::Vector) = sim_calc(probe, referent)^3

act_calc(probe::Vector, referent::Matrix) = sim_calc(probe, referent).^3


"""
"""
function recall_summary(data)
    corr = sum(data .== :Correct)
    comm = sum(data .== :Comm)
    omm = sum(data .== :Omm)
    return [corr, comm, omm]
end

"""
    echo_intensity()

Hintzman's (1984) method of summation of activation values.

# Parameters
  - `probe`: Vector of integers representing a single item.
  - `referent`: Vector or matrix of integers to which the probe is compared.

"""
echo_intensity(probe::Vector, referent::Matrix) = sum(act_calc(probe, referent))


"""
    echo_content()

Hintzman's (1984) echo content method. Sums the product of the probe and memory vectors, 
weighted by their respective activations. The resulting vector should resemble the target
item (if it is represented in memory). The out vector is normalized to the max value for
easier comparison against existing vectors.

# Parameters
  - `probe`: Vector of integers representing a single item.
  - `referent`: Vector or matrix of integers to which the probe is compared.
  - `normalize`: Should the resulting vector be normalized by the max value?

"""
function echo_content(probe::Vector, referent::Matrix, normalize=true)
    out_vec = zeros(size(probe))
    for i in 1:size(referent,1)
        out_vec .+= (act_calc(probe, @view referent[i,:]).* @view referent[i,:])
    end
    normalize ? (return out_vec ./ maximum(out_vec)) : (return out_vec)
end

"""
    block_header(txt)
Generates blocked headers with centered titles because I got bored. (TC)
# Arguments
- `txt`: String to be included in header
"""
function block_header(txt)
    bar = "###############################################################################################"
    if length(txt)+2 > length(bar)
        error("Text cannot be longer than 93 characters")
    end
    start = Int32(round(length(bar)/2) - round(length(txt)/2))
    mid_start = "#" * repeat(" ", start-1) 
    mid_end = repeat(" ", length(bar)-length(mid_start*txt)-1) * "#"
    out = bar * "\n" * mid_start * txt * mid_end * "\n" * bar
    print(out)
end

"""
    line_header(txt)
# Arguments
  - `txt`: String to be included in header. (REQUIRED)
  - len_char: Length of the title. (OPTIONAL)
"""
function line_header(txt; len_char=93)
    start = Int32(round(len_char/2) - round(length(txt)/2))
    mid_start="#" * repeat("~",start)
    mid_end = repeat("~", len_char-length(mid_start*txt)-1)
    print(mid_start * " " * txt * " " * mid_end * "#")
end