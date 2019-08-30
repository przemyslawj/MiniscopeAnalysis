% Load 'ms' saved file into workspace to run the script

addpath('/mnt/DATA/Prez/code/cheeseboard_analysis/matlab')

subject = ms.Experiment;
ncells = ms.numNeurons;
max_time_min = 4;
A = squeeze(max(ms.SFPs,[], 3));

%% Draw cells
selected_cells = [6 8 18 25 35 39];
%selected_cells = 28:40;
figure;
draw_threshold=5;
hold on;
imagesc(A);
colormap gray;
for cell_idx = selected_cells
    sfp = squeeze(ms.SFPs(:, :, cell_idx));
    s = regionprops(sfp > draw_threshold,'all');
    centroid = round([s.Centroid]);
    outline = round([s.ConvexHull]);
    plot(outline(:,1), outline(:,2), 'LineWidth', 3)
    %text(centroid(1) + 8, centroid(2), num2str(cell_idx), 'Color', 'White');
end

hold off;
xlim([75 290]);
ylim([40 240]);
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

for i = selected_cells
    signal_scaler = 3;
    trace = ms.RawTraces(:,i)';
    
    [eventVec, normApt, thresholds] = findEvents(trace', 5, 20);
    trace = trace - mean(trace);
    
    shifted_trace = trace/signal_scaler + current_shift;
    plot(timestamps_min, shifted_trace, 'LineWidth', 1);
    event_timestamps_min = timestamps_min(eventVec > 0);
    %plot(event_timestamps_min, repmat(current_shift+0.7, numel(event_timestamps_min), 1), 'r*',...
    %    'MarkerSize',2);
    %plot(timestamps_min, repmat(current_shift + thresholds(1) / signal_scaler, 1, length(timestamps_min)), 'r--');
    
    current_shift = current_shift + zshift;
end

hold off;
xlim([0 max_time_min]);

% function A = zscore(traces)
%     A = traces - mean(traces, 2);
%     A = bsxfun(@rdivide, A, std(A, [], 2));
% end



