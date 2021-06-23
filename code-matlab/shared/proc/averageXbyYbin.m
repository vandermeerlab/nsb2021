function x_avg = averageXbyYbin(x,y,y_edges)
% function x_avg = averageXbyYbin(x,y,y_edges)
%
% Bins variable y into bins defined by y_edges; then for each y-bin,
% computes the average of x. Inputs x and y must have the same length, 
% and each element is assumed to correspond to the same time.
% (note you can use interp1() to make them the same length)
%
% This works by finding the indices of y that go into each y-bin, and
% then for each bin averaging the x-values corresponding to those idxs.
%
% Example: you have firing rate as a function of time, and you have
% position as a function of time. Get the average firing rate for each
% position bin:
%
% fr_avg_bin = averageXbyYbin(fr, pos, pos_edges);

[~,idx] = histc(y,y_edges);

x_avg = zeros(size(y_edges));
for iBin = length(y_edges):-1:1
    
    if sum(idx == iBin) ~= 0 % at least one sample in this bin
        x_avg(iBin) = nanmean(x(idx == iBin));
    end
    
end
x_avg = x_avg(1:end-1);

% fast but memory-intensive
%bins = min(max(idx,1),length(y_edges)-1); % eliminate last edge
%ypos = ones(size(bins,1),1);
%ns = sparse(bins,ypos,1);
%xsum = sparse(bins,ypos,x);
%x_avg = full(xsum)./(full(ns));


