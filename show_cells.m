% Load 'ms' saved file into workspace to run the script

addpath('/mnt/DATA/Prez/code/cheeseboard_analysis/matlab')

subject = ms.Experiment;
ncells = ms.numNeurons;

A = squeeze(max(ms.SFPs,[], 3));

%% Draw cells
figure;
imagesc(A);
colormap gray
hold on;

for cell_idx = 1:ncells
    %outline = outlines{cell_idx};
    %plot(outline(:,1), outline(:,2));
    sfp = squeeze(ms.SFPs(:, :, cell_idx));
    s = regionprops(sfp,'centroid');
    centroid = round([s.Centroid]);
    text(centroid(1) + 2, centroid(2), num2str(cell_idx), 'Color', 'White');
end

hold off;

%% Align timestamps in case of missing frames
sessionLengths = cell2mat(ms.sessionLengths)';
if numel(ms.time) > size(ms.RawTraces, 1)
    sessionStartsIndex = find(diff(ms.time)<0) + 1;
    sessionStartsIndex = [1; sessionStartsIndex];
    sessionEndsIndex = sessionStartsIndex - 1 + sessionLengths;
    
    time2 = [];
    for i = 1:numel(sessionStartsIndex)
        time2 = [time2; ms.time(sessionStartsIndex(i):sessionEndsIndex(i))];
    end
    ms.time = time2;
end
timestamps = ms.time;

%% Plot traces
figure;
hold on;
zshift = 1;
current_shift = 1;
last_index = 0;
for session_i = 1:(numel(sessionLengths) - 1)
    last_index = sessionLengths(session_i) + last_index;
    session_offset = ms.time(last_index);
    for time_i = (last_index + 1) : numel(ms.time)
        timestamps(time_i) = timestamps(time_i) + session_offset;
    end
end
timestamps_min = timestamps / 1000 / 60;

for i = 1:ncells
    signal_scaler = 3;
    trace = ms.RawTraces(:,i)';
    
    [eventVec, normApt, thresholds] = findEvents(trace', 5, 20);
    trace = trace - mean(trace);
    
    shifted_trace = trace/signal_scaler + current_shift;
    plot(timestamps_min, shifted_trace);
    event_timestamps_min = timestamps_min(eventVec > 0);
    plot(event_timestamps_min, repmat(current_shift+0.7, numel(event_timestamps_min), 1), 'r*',...
        'MarkerSize',2);
    plot(timestamps_min, repmat(current_shift + thresholds(1) / signal_scaler, 1, length(timestamps_min)), 'r--');
    
    current_shift = current_shift + zshift;
end

hold off;

% function A = zscore(traces)
%     A = traces - mean(traces, 2);
%     A = bsxfun(@rdivide, A, std(A, [], 2));
% end



