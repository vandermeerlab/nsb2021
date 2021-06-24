function ts_out = AddTimeToTS(ts_in, dt)
% function ts_out = AddTimeToTS(ts_in, dt)
%
% adds time dt to the contents of all .t cells in a ts

myfun = @(x) x + dt;

ts_out = ts_in;
ts_out.t = cellfun(myfun, ts_in.t, 'UniformOutput', false);

