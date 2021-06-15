%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT RAW PHOTOMETRY SIGNAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dsRate = 100;
sigEdge = 15;

%% From raw WS (CW)
rawFs = data.gen.acqFs;
Fs = data.gen.Fs;
time = data.final.time;

raw_FP = data.acq.FP{1};
raw_FP = raw_FP((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
raw_FP = downsample(raw_FP, dsRate);

%% Plotting raw signals across different time scales
sessionTitle = 'raw_';
time_ranges = [10, 100, 500];

for t_i = 1:length(time_ranges)
    t_range = 1:Fs*time_ranges(t_i);
    subplot(3, 1, t_i);
    plot(time(t_range), raw_FP(t_range), 'Color', [0 0.5 0])
    title([sessionTitle, num2str(time_ranges(t_i))], 'Interpreter','none')
    ylabel('Raw fluorescence (V)'); xlabel('Time (s)');
end

%% From processed WS (CW)
Fs = data.gen.Fs;
time = data.final.time;
FP = data.final.FP{1};

%% Plotting processed signals across different time scales
sessionTitle = 'CW470_';
time_ranges = [10, 30, 60];

for t_i = 1:length(time_ranges)
    t_range = 1:Fs*time_ranges(t_i);
    subplot(3, 1, t_i);
    plot(time(t_range), FP(t_range), 'Color', [0 0.5 0])
    title([sessionTitle, num2str(time_ranges(t_i))], 'Interpreter','none')
    ylabel('Fluorescence (dF/F)'); xlabel('Time (s)');
end