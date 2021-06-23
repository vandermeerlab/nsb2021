function [trial_start, trial_end, trial_id] = GetGapTrialTimes(cfg_in, evt)
% function [trial_start, trial_end, trial_id] = GetGapTrialTimes(cfg, evt_in)
%
% obtain trial start and end times from nsb2021 gap junction task events file
%
% example:
%   cfg_in.trial_start_label = '6'; % use only event label '6' as trial start
%
% example:
%   cfg_in.trial_start_label = []; % autodetect labels from '0' to '9' 

cfg_def = [];
cfg = ProcessConfig(cfg_def, cfg_in);

cfg_next.mode = 'next'; cfg_prev.mode = 'prev';

trial_start = []; trial_end = []; trial_id = [];

if isfield(cfg, 'trial_start_label')
    if strmatch(cfg.trial_start_label, evt.label, 'exact')
        all_trial_start = getd(evt, cfg.trial_start_label);
        all_trial_id = repmat(str2num(cfg.trial_start_label), size(all_trial_start));
    else
        warning('No events found');
        return;
    end
else
    % figure out what the start events are called
    all_trial_start = []; all_trial_id = [];
    for iL = 0:9 % try all numbers 0 to 9
       
        if strmatch(num2str(iL), evt.label, 'exact')
            
            this_t = getd(evt, num2str(iL)); n_t = length(this_t);
            
            all_trial_start = cat(2, all_trial_start, this_t);
            all_trial_id = cat(2, all_trial_id, repmat(iL, [1 n_t]));
            
        end
        
    end
    
end

all_trial_end = getd(evt,'h');

%
fprintf('Number of trial starts found: %d\n', length(all_trial_start));
fprintf('Number of trial ends found: %d\n', length(all_trial_end));


if length(all_trial_start) > length(all_trial_end) % count back from trial ends
    for iT = 1:length(all_trial_end)
       temp.t = all_trial_start;
       if ~isempty(FindFieldTime(cfg_prev,temp,all_trial_end(iT)))
           trial_start(iT) = FindFieldTime(cfg_prev,temp,all_trial_end(iT));
           trial_start_idx = find(all_trial_start == trial_start(iT)); % idx of identified start
           trial_id(iT) = all_trial_id(trial_start_idx);
       else
           error(sprintf('Trial end %d has no corresponding start', iT));
       end
       
    end
    trial_end = all_trial_end;
elseif length(all_trial_start) < length(all_trial_end) % count fwd from trial starts
     for iT = 1:length(all_trial_start)
       temp.t = all_trial_end;
       if ~isempty(FindFieldTime(cfg_next,temp,all_trial_start(iT))) 
           trial_end(iT) = FindFieldTime(cfg_next,temp,all_trial_start(iT));
       else
           error(sprintf('Trial start %d has no corresponding end.', iT));
       end
     end
    trial_start = all_trial_start;
    trial_id = all_trial_id;
else % must be equal
    trial_start = all_trial_start;
    trial_end = all_trial_end;
    trial_id = all_trial_id;
end