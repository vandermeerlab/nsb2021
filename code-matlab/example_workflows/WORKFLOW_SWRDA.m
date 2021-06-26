cd('C:\data\NSB2021\M21-062_2021-06-23_novelobject');
%cd('C:\data\NSB2021\M21-062_2021-06-22');
%cd('C:\data\NSB2021\M21-062_2021-06-24_novelobject_control');
%cd('C:\data\NSB2021\M21-062_2021_06-24_control_CB1');
%cd('C:\data\NSB2021\M21-063-2021-06-24_raclopride');

evt = LoadEvents([]);
t_start = getd(evt, 'Starting Recording');
t_end = getd(evt, 'Stopping Recording');

LoadExpKeys;
%please.fc = [ExpKeys.photo ExpKeys.goodSWR ExpKeys.noSWR];  
%csc = LoadCSC(please); % fails because data is unequal length

please.fc = ExpKeys.photo; photo_csc = LoadCSC(please);
please.fc = ExpKeys.goodSWR; csc = LoadCSC(please);
please.fc = ExpKeys.noSWR; csc_no = LoadCSC(please);

%% preprocess photometry data
cfg = [];
cfg.f = 20; cfg.bandtype = 'lowpass';
photo_cscF = FilterLFP(cfg, photo_csc);
photo_cscF.data = locdetrend(photo_cscF.data, 2000, [30 1])';
%photo_cscF.data = locdetrend(photo_cscF.data, 2000)';
%photo_cscF = zscore_tsd(photo_cscF);

%% detect SWRs (simple)
cfg_swr = [];
cfg_swr.thr1 = 5; cfg_swr.thr2 = 2;
cfg_swr.thr1_artif = 3; cfg_swr.thr2_artif = 1.5;
cfg_swr.f = [130 200];
SWR_evt = DetectSWRs(cfg_swr, csc, csc_no);

%% detect SWRs (using training data, if exists)
load(FindFile('*manualIV.mat')); % loads evt variable
ncfs = SWRfreak([], evt, csc);
SWR_score = amSWR([], ncfs, csc);
SWR_score_no = amSWR([], ncfs, csc_no);

SWR_evt_yes = DualThresholdDetect([], SWR_score);
SWR_evt_no = DualThresholdDetect([], SWR_score_no);
SWR_evt = DifferenceIV([], SWR_evt_yes, SWR_evt_no);

%% plot
PlotTSDfromIV([], SWR_evt, csc);

%% ..or the events alone (fixed 200ms window centered at event time)
cfg = []; cfg.display = 'iv'; cfg.mode = 'center'; cfg.fgcol = 'k';
PlotTSDfromIV(cfg, SWR_evt, csc);

 %% ..hold on (highlight edges of event on top of previous plot)
cfg = [];
cfg.display = 'iv';
cfg.fgcol = 'r';
 
PlotTSDfromIV(cfg, SWR_evt, csc);

%% split SWRs according to power
low_idx = SWR_evt.usr.max < median(SWR_evt.usr.max); SWR_evt_low = SelectIV([], SWR_evt, low_idx);
hi_idx = SWR_evt.usr.max >= median(SWR_evt.usr.max); SWR_evt_hi = SelectIV([], SWR_evt, hi_idx);


%%
%SWR_evt = restrict(SWR_evt, t_start(end), t_end(end));

cfg_peth = [];
%cfg_peth.normalize = [-2 0];
cfg_peth.window = [-5 5];
out = TSDpeth(cfg_peth, photo_cscF, SWR_evt.tstart);
out_low = TSDpeth(cfg_peth, photo_cscF, SWR_evt_low.tstart);
out_high = TSDpeth(cfg_peth, photo_cscF, SWR_evt_hi.tstart);

clear all_out;
for iShuf = 100:-1:1
   
    this_photoZ = photo_cscF;
    this_photoZ.data = circshift(this_photoZ.data, round(rand(1).*length(this_photoZ.data)));
    
    this_out = TSDpeth(cfg_peth, this_photoZ, SWR_evt.tstart);
    
    all_out(iShuf, :) = this_out.data;
end

%%
plot(out.tvec, out.data, 'k', 'LineWidth', 2);
hold on;
plot(out.tvec, nanmean(all_out), 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);
plot(out.tvec, nanmean(all_out)+2*nanstd(all_out,[],1), '--', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);
plot(out.tvec, nanmean(all_out)-2*nanstd(all_out,[],1), '--', 'LineWidth', 1, 'Color', [0.7 0.7 0.7]);
xlabel('time from SWR (s)'); ylabel('detrended [DA]');
vline(0); box off; set(gca, 'TickDir', 'out', 'FontSize', 18, 'XLim', [-5 5]);

%%
plot(out.tvec, out_low.data, 'LineWidth', 1, 'Color', [0.5 0.5 1]);
plot(out.tvec, out_high.data, 'LineWidth', 1, 'Color', [1 0.5 0.5]);