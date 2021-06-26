cd('C:\data\NSB2021\M21-062_2021-06-23_novelobject');

%%
global vid
vid.tvec = read_smi(FindFile('*.smi'));
vid.Obj = VideoReader(FindFile('*.mp4'));

fprintf('smi: %d timestamps, video: %d frames\n', length(vid.tvec), vid.Obj.NumberOfFrames);

%%
LoadExpKeys;
please = [];
please.fc = ExpKeys.photo; 
photo_csc = LoadCSC(please);

%% check that timestamps align
plot(photo_csc)
hold on;
plot(vid.tvec(end), 0, 'or')

%% some plotting parameters
cfg_plot = [];
cfg_plot.twin = [-1 1];
cfg_plot.dt = 0.1;

%%
global t hdl;
t = vid.tvec(end) - 100;

fh = figure('KeyPressFcn', @update_fig);
hdl.s1h = subplot(4, 1, [1 2]);
hdl.s2h = subplot(4, 1, 3);

axes(hdl.s2h);
plot(photo_csc);
set(gca, 'XLim', cfg_plot.twin + t);

%% a loop
t = t_start;
for iF = 1:10
   
    % video
    idx = nearest_idx3(t, video_tvec); % find which frame to load
    this_frame = read(vidObj, idx);
    axes(hdl.s1h); imshow(this_frame);
    
    set(hdl.s2h, 'XLim', cfg_plot.twin + t); % update csc axes
    
    t = t + cfg_plot.dt;
    pause(1)
end

%% interactive version using callback function