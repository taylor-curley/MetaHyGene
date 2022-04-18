
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