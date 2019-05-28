% Load 'ms' saved file into workspace to run the script

subject = ms.Experiment;
ncells = ms.numNeurons;

A = squeeze(max(ms.SFPs,[], 3));

%% Draw cells
figure;
%imagesc(maxIntensityMovie);
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

%% Plot traces
figure;
hold on;
zshift = 1;
current_shift = 1;

timestamps = ms.time;
for session_i = 1:(numel(ms.sessionLengths) - 1)
    last_index = ms.sessionLengths{session_i};
    session_offset = timestamps(last_index);
    for time_i = (last_index + 1) : numel(ms.time)
        timestamps(time_i) = timestamps(time_i) + session_offset;
    end
end
timestamps_min = (1:numel(timestamps)) / 1000 / 60;

for i = 1:ncells
    norm_trace = zscore(ms.RawTraces(:,i)') / 10;
    shifted_trace = norm_trace + current_shift;
    plot(timestamps_min, shifted_trace);
    
    current_shift = current_shift + zshift;
end

hold off;

function A = zscore(traces)
    A = traces - mean(traces, 2);
    A = bsxfun(@rdivide, A, std(A, [], 2));
end



