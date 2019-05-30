%% run more iterations
neuron.update_background_parallel(use_parallel);
neuron.update_spatial_parallel(use_parallel);
neuron.update_temporal_parallel(use_parallel);

K = size(neuron.A,2);
tags = neuron.tag_neurons_parallel();  % find neurons with fewer nonzero pixels than min_pixel and silent calcium transients
neuron.remove_false_positives();
neuron.merge_neurons_dist_corr(show_merge);

% merge components with highly correlated spatial shapes (corr=0.8) and small temporal correlations (corr=0.1)
merge_thr_spatial = [0.8, 0.2, -inf];
neuron.merge_high_corr(show_merge, merge_thr_spatial);

if K~=size(neuron.A,2)
    neuron.update_spatial_parallel(use_parallel);
    neuron.update_temporal_parallel(use_parallel);
    neuron.remove_false_positives();
end

%% save the workspace for future analysis
neuron.orderROIs('snr');
cnmfe_path = neuron.save_workspace();
disp(['Saved workspace to: ', cnmfe_path])

%% display neurons
dir_neurons = sprintf('%s%s%s_neurons%s', ms.dirName, filesep, ms.analysis_time, filesep);
neuron.save_neurons(dir_neurons); 

%% update ms struct
ms.Options = neuron.options;

ms.Centroids = neuron.estCenter;
ms.CorrProj = neuron.Cn;
ms.PeakToNoiseProj = neuron.PNR;

ms.FiltTraces = neuron.C';
ms.RawTraces = neuron.C_raw';
ms.SFPs = neuron.reshape(neuron.A, 2);
ms.numNeurons = size(ms.SFPs,3);
