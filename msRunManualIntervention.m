% Set cnmfe_matfile if not in the environment
%cnmfe_matfile = '/mnt/DATA/Prez/ca_img/wheel/2019-05-31/1R-dCA1/31-May-2019_17-07-03/msvideo_source_extraction/frames_1_1929/LOGS_31-May_17_13_35/31-May_17_16_55.mat'
load(ms.cnmfe_matfile);
load([ms.dirName filesep 'ms.mat']);


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
