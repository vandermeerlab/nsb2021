function [trial_start, trial_end] = GetGapTrialTimes(cfg_in, evt)
% function [trial_start, trial_end] = GetGapTrialTimes(cfg, evt_in)
%
% obtain trial start and end times from gap junction task events file

cfg_def = [];

cfg = ProcessConfig(cfg_def, cfg_in);


cfg_next.mode = 'next'; cfg_prev.mode = 'prev';

all_trial_start = getd(evt,'6');
all_trial_end = getd(evt,'h');

if length(all_trial_start) > length(all_trial_end) % count back from trial ends
    for iT = 1:length(all_trial_end)
       temp.t = all_trial_start;
       trial_start(iT) = FindFieldTime(cfg_prev,temp,all_trial_end(iT));       
    end
    trial_end = all_trial_end;
elseif length(all_trial_start) < length(all_trial_end) % count fwd from trial starts
     for iT = 1:length(all_trial_end)
       temp.t = all_trial_end;
       trial_end(iT) = FindFieldTime(cfg_next,temp,all_trial_start(iT));       
     end
    trial_start = all_trial_start;
else % must be equal
    trial_start = all_trial_start;
    trial_end = all_trial_end;
end