"""
    cued_recall(model::MHG, threshold::Float64)

Simple cued recall task. The `model` object is of type `MHG` and reads different parameters
from that object. The `threshold` parameter controls the recall mechanism by setting a lower
limit to activation values.

# Arguments
  - `model`: Data structure of type `MHG`.
  - `threshold`: Numerical value indicating the threshold of the recall mechanism.

"""
function cued_recall(model, threshold::Float64)
    out_data = DataFrame(Subject = Int64[],
                         Trial = Int64[],
                         EchoInt = Float64[],
                         Target = Int64[],
                         RESP = Int64[],
                         Outcome = Symbol[])
    # I don't think you need to differentiate between subjects and trials if iid 
    for sub in 1:model.n_subs
        trial_list = shuffle!([1:model.n_trials;])
        for i in 1:model.n_trials
            probe = model.cues[trial_list[i],:]
            # I recommend adding zeros to the probe upon initializing the model 
            probe = vcat(probe, zeros(length(probe)))
            echo_int, resp, outcome = recall_trial(probe, model.cues, model.targets, threshold, trial_list[i])
            push!(out_data, [sub, i, echo_int, trial_list[i], resp, outcome])
        end
    end
    return out_data
end

"""
    recall_trial(probe, cues, targets, threshold, answer)

Single cued-recall trial. Subprocess under the `cued_recall()` method.

# Arguments
  - `probe`: Vector for the probe item into memory. The first half of the vector is the true cue vector (degraded, if specified) while the second half is a vector of zeros.
  - `cues`: Matrix of cue-word representations being held in memory.
  - `targets`: Matrix of target-word representations being held in memory.
  - `threshold`: Float value for the threshold parameter for the cued recall procedure.
  - `answer`: Index of the correct answer. Necessary for determining the outcome of the memory test.

"""
function recall_trial(probe, cues, targets, threshold, answer)  
    memory = hcat(cues, targets)  
    ec_in = echo_intensity(probe, memory)
    ec_con = round.(echo_content(probe, memory))
    ec_target = ec_con[Int(length(ec_con)/2)+1:length(ec_con)]
    target_acts = act_calc(ec_target, targets)
    sum(target_acts .> threshold) > 0 ? recall = argmax(target_acts) : (recall = 0; outcome = :Omm)
    recall == answer ? outcome = :Correct : outcome = :Comm
    return ec_in, recall, outcome
end