
""" 
    recognition(n_subs, n_features, n_trials, decay, threshold)

"""
function recognition(n_subs::Int64, n_features::Int64, n_trials::Int64, decay::Float64, threshold::Float64)
    out_data = DataFrame(Subject = Int64[],
                        Trial = Int64[],
                        EchoInt = Float64[],
                        RESP = Int64[],
                        ACC = Int64[],
                        Target_Present = Int64[])
    for sub in 1:n_subs
        # Half stimuli are old, half are new
        stimuli = sim_controller(n_features,n_trials)
        memory = trace_replicator(stimuli[1:Int(n_trials/2),:], decay)
        ech_int = []; resp = []; acc = []; present = [];
        for trial in 1:n_trials
            ech_int = echo_intensity(stimuli[trial,:],memory)
            trial <= n_trials/2 ? (present = 1) : (present = 0)
            if ech_int > threshold
                resp = 1
                trial <= n_trials/2 ? (acc = 1) : (acc = 0)
            else
                resp = 0
                trial <= n_trials/2 ? (acc = 0) : (acc = 1)
            end   
            push!(out_data, [sub,trial,ech_int,resp,acc,present])         
        end
    end
    return out_data
end

"""
    cued_recall(; n_subs, n_trials, n_features, relatedness, decay, threshold, kmax)

# Parameters
  - `n_subs`: Number of subjects (blocks) to simulate.
  - `n_trials`: Number of trials (per subject) to simulate.
  - `n_features`: Number of features in each item vector. Cues and targets are considered to be separate vectors.
  - `relatedness`: Degree to which the cues and targets are related. Between `0.0` and `1.0`.
  - `decay`: Degree of trace decay. Between `0.0` and `1.0`.
  - `threshold`: Recall retrieval threshold. Between `0.0` and `1.0`.
  - `kmax`: Maximum number of retrieval failures. 

"""
function cued_recall(;n_subs=10, n_trials=60, n_features=20, relatedness=0.5, decay=0.2, threshold=0.2, kmax=20)
    recall_data = DataFrame(Subject = Int64[],
                            Trial = Int64[],
                            Recall = Int64[],
                            Outcome = Symbol[],
                            Accuracy = Int64[],
                            Activation = Float64[])
    for sub in 1:n_subs
        cues, targets = sim_controller(n_features, n_trials, relatedness)
        stimuli = hcat(cues, targets)
        memory = trace_replicator(stimuli, decay)
        for trial in 1:n_trials
            probe = vcat(cues[trial,:],zeros(n_features))
            recall, outcome, activation = cued_recall_trial(probe, trial, memory, threshold, kmax)
            outcome == :Correct ? (acc = 1) : (acc = 0)
            push!(recall_data, [sub, trial, recall, outcome, acc, activation])
        end
    end
    return recall_data
end

"""
    cued_recall_trial(probe, target, memory, threshold, kmax)

Simulates a cued recall trial in the style of HyGene. The sequence of events is:

1. A probe vector is "bounced" off of memory. A vector of echo content (representation 
of the target) returns.
2. The echo content is compared against all target representations in memory. Activations
are calculated. Only above-threshold activations are kept.
3. Analyze above-threshold activations:
  * If there are no above-threshold activations, return "omission".
  * If there is only one above-threshold activation, return that item as the answer.
  * Loop through above-threshold activations while Kmax has not been reached:
    + Set minimum activation as threshold and `k` to zero.
    + Randomly select item. If the activation is above the minumum activation, add item
      to the set of contenders and set the new minimum activation as the activation of 
      the selected item. If the activation is not above the minimum activation, increase
      the retrieval failure count `k`.
    + When maximum number of retrieval failures is reached, choose the highest-activated
      item as answer.

# Parameters
  - `probe`: Item vector to probe memory. 
  - `target`: Integer indicating the position of the correct target item.
  - `memory`: Matrix of degraded item vectors.
  - `threshold`: Cued recall retrieval threshold.
  - `kmax`: Maximum number of retrieval attempts

"""
function cued_recall_trial(probe, target, memory, threshold, kmax)
    n_features = Int(length(probe)/2)
    # Extract echo content from probe
    memory_hologram = echo_content(probe, memory, true)
    target_hologram = memory_hologram[Int((n_features/2)+1):n_features]
    # Retrieve possible target activations
    target_activations = act_calc(target_hologram,memory[:,Int((n_features/2)+1):n_features])
    possible_targets = findall(target_activations .> threshold)
    # Iterate through above-threshold activations
    act_min = threshold
    set_of_contenders = []
    if length(possible_targets) == 0 
        recall = 0
        outcome = :Omission
        activation = NaN
    else
        if length(possible_targets) == 1
            recall = possible_targets[1]
            recall == target ? (outcome = :Correct) : (outcome = :Commission)
            activation = target_activations[possible_targets[1]]
        else
            k = 0
            while k < kmax
                rand_item = sample(possible_targets)
                if target_activations[rand_item] > act_min 
                    push!(set_of_contenders, rand_item)
                    act_min = target_activations[rand_item]
                else
                    k += 1
                end
            end
            if length(set_of_contenders) > 0
                recall = set_of_contenders[argmax(target_activations[set_of_contenders])]
                recall == target ? (outcome = :Correct) : (outcome = :Commission)
                activation = maximum(target_activations[set_of_contenders])
            else
                recall = 0
                outcome = :Omission
                activation = NaN
            end
        end
    end
    return recall, outcome, activation
end