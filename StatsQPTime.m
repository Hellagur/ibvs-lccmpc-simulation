%% STATISTICS QP SOLVING TIME
%
% This function reads all simulation result .mat files from the specified path,
% where files are named 1.mat, 2.mat, ..., N.mat, and collects the QP
% solving time statistics: average, maximum, minimum.
%
% Usage:
%   [avg_time, max_time, min_time] = StatsQPTime('path/to/data', N);
%
% Inputs:
%   path - directory path containing result files
%   N    - number of files to process
%
% Outputs:
%   avg_time - average solving time (ms)
%   max_time - maximum solving time (ms)
%   min_time - minimum solving time (ms)

function [avg_time, max_time, min_time] = StatsQPTime(path, N)

    all_time = zeros(N, 1);
    valid_count = 0;

    for i = 1:N
        fname = fullfile(path, [num2str(i), '.mat']);
        if ~exist(fname, 'file')
            warning('File %s does not exist, skipping.', fname);
            continue;
        end

        data = load(fname);
        if isfield(data, 'hist') && isfield(data.hist, 'tcon')
            % tcon contains time for each step in one simulation
            % take average for this simulation, or just collect all steps
            all_time(i) = mean(data.hist.tcon * 1000);  % convert to ms
            valid_count = valid_count + 1;
        else
            warning('File %s does not contain hist.tcon, skipping.', fname);
        end
    end

    % Remove empty entries
    all_time = all_time(all_time > 0);

    avg_time = mean(all_time);
    max_time = max(all_time);
    min_time = min(all_time);

    fprintf('==================================================\n');
    fprintf('QP solving time statistics (%d files processed):\n', valid_count);
    fprintf('  Average time:  %.2f ms\n', avg_time);
    fprintf('  Maximum time: %.2f ms\n', max_time);
    fprintf('  Minimum time: %.2f ms\n', min_time);
    fprintf('==================================================\n');

end
