cd('C:\data\NSB2021\M21-062_2021-06-23_novelobject');

%%
video_tvec = read_smi(FindFile('*.smi'));
vidObj = VideoReader(FindFile('*.mp4'));

fprintf('smi: %d timestamps, video: %d frames\n', length(video_tvec), vidObj.NumberOfFrames);

%%
LoadExpKeys;
please = [];
please.fc = ExpKeys.photo; 
photo_csc = LoadCSC(please);

%% check that timestamps align
plot(photo_csc)
hold on;
plot(video_tvec(end), 0, 'or')

%% some plotting parameters
cfg_plot = [];
cfg_plot.twin = [-1 1];
cfg_plot.dt = 0.1;

%%
t_start = video_tvec(end) - 100;

fh = figure;
s1h = subplot(4, 1, [1 2]);
s2h = subplot(4, 1, 3);

axes(s2h);
plot(photo_csc);

t = t_start;
for iF = 1:10
   
    % video
    idx = nearest_idx3(t, video_tvec); % find which frame to load
    this_frame = read(vidObj, idx);
    axes(s1h); imshow(this_frame);
    
    set(s2h, 'XLim', cfg_plot.twin + t); % update csc axes
    
    t = t + cfg_plot.dt;
    pause(1)
end