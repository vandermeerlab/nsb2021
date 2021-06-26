function SWR_evt = DetectSWRs(cfg_in, csc_yes, varargin)
% function SWR_evt = DetectSWRs(cfg_in, csc_yes, varargin)
%
% detect SWR events based on thresholded ripple-band envelope
%
% if optional third argument (a csc) is supplied, functions as exclusive-or
% (veto), i.e. SWR is detected only if threshold passed on csc_yes but not
% on csc_no
%
% varargins:
%
% cfg_def.f = [140 220];
% cfg_def.thr1 = 5; % SDs above mean for SWR to be included
% cfg_def.thr2 = 3; % SDs above mean for start and end time detection
%
% MvdM, NS&B 2021

cfg_def = [];
cfg_def.f = [140 220];
cfg_def.thr1 = 5; % SDs above mean for SWR to be included
cfg_def.thr2 = 3; % SDs above mean for start and end time detection
cfg_def.thr1_artif = 3;
cfg_def.thr2_artif = 1;

cfg_master = ProcessConfig(cfg_def, cfg_in);

if nargin == 3
   
    csc_no = varargin{1};
    if ~CheckTSD(csc_yes)
        error('Optional third argument must be a tsd.');
    end
        
end

%
cfg_f = [];
cfg_f.f = cfg_master.f;
csc_yesF = FilterLFP(cfg_f, csc_yes);

%
csc_yesP = LFPpower([], csc_yesF);
csc_yesPz = zscore_tsd(csc_yesP);

%% detect events
cfg = [];
cfg.method = 'raw';
cfg.threshold = cfg_master.thr2;
cfg.operation =  '>'; % return intervals where threshold is exceeded
cfg.merge_thr = 0.05; % merge events closer than this
cfg.minlen = 0.05; % minimum interval length
 
SWR_evt = TSDtoIV(cfg,csc_yesPz);
 
%% to each event, add a field with the max z-scored power (for later selection)
cfg = [];
cfg.method = 'max'; % 'min', 'mean'
cfg.label = 'max'; % what to call this in iv, i.e. usr.label
 
SWR_evt = AddTSDtoIV(cfg, SWR_evt, csc_yesPz);
 
%% select only those events of >5 z-scored power
cfg = [];
cfg.operation = '>';
cfg.threshold = cfg_master.thr1;
 
SWR_evt = SelectIV(cfg, SWR_evt, 'max');

%% 

cfg_artif = cfg_master;
cfg_artif.thr1 = cfg_artif.thr1_artif;
cfg_artif.thr2 = cfg_artif.thr2_artif;

if exist('csc_no', 'var') % "veto" csc
    noSWR_evt = DetectSWRs(cfg_artif, csc_no); 
    SWR_evt = DifferenceIV([], SWR_evt, noSWR_evt);
end