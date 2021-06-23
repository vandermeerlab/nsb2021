%%
cd('Z:\NSB_2021\03 Mouse\ephys-fiber-data\incoming\M21-062\M21-062-2021-06-22_screening_goodSWR');
LoadExpKeys;

please = [];
please.fc = ExpKeys.goodSWR;
csc = LoadCSC(please);

please.fc = ExpKeys.noSWR;
csc_no = LoadCSC(please);

%%
SWR_evt = DetectSWRs([], csc, csc_no);

%%
PlotTSDfromIV([], SWR_evt, csc);

%% ..or the events alone (fixed 200ms window centered at event time)
close all;
 
cfg = [];
cfg.display = 'iv';
cfg.mode = 'center';
cfg.fgcol = 'k';
 
PlotTSDfromIV(cfg, SWR_evt, csc);
%% ..hold on (highlight edges of event on top of previous plot)
cfg = [];
cfg.display = 'iv';
cfg.fgcol = 'r';
 
PlotTSDfromIV(cfg, SWR_evt, csc);