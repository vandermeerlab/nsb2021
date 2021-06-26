function evt = DualThresholdDetect(cfg_in, csc)
% function evt = DualThresholdDetect(cfg, csc)
%
% cfg_def.thr1 = 2; % sets start and end, determines length
% cfg_def.thr2 = 5; % must have at least this much power somewhere to be included

cfg_def.thr1 = 2; % sets start and end, determines length
cfg_def.thr2 = 5; % must have at least this much power somewhere to be included

cfg_master = ProcessConfig(cfg_def, cfg_in);

%% detect events
cfg = [];
cfg.method = 'raw';
cfg.threshold = cfg_master.thr1;
cfg.operation =  '>'; % return intervals where threshold is exceeded
cfg.merge_thr = 0.05; % merge events closer than this
cfg.minlen = 0.05; % minimum interval length
 
evt = TSDtoIV(cfg, csc);
 
%% to each event, add a field with the max z-scored power (for later selection)
cfg = [];
cfg.method = 'max'; % 'min', 'mean'
cfg.label = 'max'; % what to call this in iv, i.e. usr.label
 
evt = AddTSDtoIV(cfg, evt, csc);
 
%% select only those events of >5 z-scored power
cfg = [];
cfg.operation = '>';
cfg.threshold = cfg_master.thr2;
 
evt = SelectIV(cfg, evt, 'max');