cnmfe_matfile = '/mnt/DATA/Prez/cheeseboard/2019-02-learning/2019-02-24/mv_caimg/1BR/28-May-2019_17-18-13/msvideo_source_extraction/frames_1_9631/LOGS_29-May_10_40_58/30-May_10_06_30.mat'
cnmfe_dir = fileparts(cnmfe_matfile);
load(cnmfe_matfile);
load([cnmfe_dir filesep 'ms.mat']);


dmin_only = 4;  % merge neurons if their distances are smaller than dmin_only.
%% Manual intervention
neuron.orderROIs('snr');   % order neurons in different ways {'snr', 'decay_time', 'mean', 'circularity'}
neuron.viewNeurons([], neuron.C_raw);
    
% merge closeby neurons
neuron.merge_close_neighbors(true, dmin_only);
    
% delete neurons
tags = neuron.tag_neurons_parallel();  % find neurons with fewer nonzero pixels than min_pixel and silent calcium transients
ids = find(tags>0);
if ~isempty(ids)
    neuron.viewNeurons(ids, neuron.C_raw);
end

msRunAfterIntervention
