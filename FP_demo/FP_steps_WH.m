%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT RAW PHOTOMETRY SIGNAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dsRate = 100;
sigEdge = 15;
rawFs = data.gen.acqFs;
Fs = rawFs/dsRate;

raw_time = data.acq.time;
raw_FP = data.acq.FP{1};

%% Plotting raw signals across different time scales
sessionTitle = 'raw_';
time_ranges = [30];

t_range = rawFs*sigEdge:rawFs*time_ranges(1);
plot(raw_time(t_range), raw_FP(t_range), 'Color', [0 0.5 0])
title([sessionTitle, num2str(time_ranges(1))], 'Interpreter','none')
ylabel('Raw fluorescence (V)'); xlabel('Time (s)');
    
%%
raw_FP = raw_FP((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
raw_FP = downsample(raw_FP, dsRate);