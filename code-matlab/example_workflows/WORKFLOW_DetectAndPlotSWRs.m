%%
cd('C:\data\NSB2021\M21-062_2021-06-22');
LoadExpKeys;

please = [];
please.fc = ExpKeys.goodSWR;
csc = LoadCSC(please);

please.fc = ExpKeys.noSWR;
csc_no = LoadCSC(please);

please.fc = ExpKeys.photo;
photo = LoadCSC(please);

t1 = 1333;
t0 = csc.tvec(1); csc.tvec = csc.tvec - t0; csc_no.tvec = csc_no.tvec - t0; photo.tvec = photo.tvec - t0;
csc = restrict(csc, 0, t1); csc_no = restrict(csc_no, 0, t1); photo = restrict(photo, 0, t1);
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

%%
photoZ = photo;
cfg = [];
cfg.f = 20; cfg.bandtype = 'lowpass';
photoZ = FilterLFP(cfg, photoZ);
photoZ.data = locdetrend(photoZ.data, 2000, [5 1])';

%%
cfg_peth = [];
out = TSDpeth(cfg_peth, photoZ, SWR_evt.tstart);

for iShuf = 100:-1:1
   
    this_photoZ = photoZ;
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
vline(0); box off; set(gca, 'TickDir', 'out');