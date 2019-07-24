parent_dir = '/mnt/DATA/Prez/ca_img/tmp/F/2017-10-31';
parent_dir = '/mnt/DATA/Prez/ca_img/miniscope_habituation/2019-07-16/mv_caimg/D-BR';

%% Parameters
spatial_downsampling = 2; % (Recommended range: 2 - 4. Downsampling significantly increases computational speed, but verify it does not
isnonrigid = false; % If true, performs non-rigid registration (slower). If false, rigid alignment (faster).
analyse_behavior = false;
with_manual_intervantion = true;

% Generate timestamp to save analysis
analysis_time = strcat(date,'_', datestr(datetime('now'), 'HH-MM-SS'));

%% 1 - Create video objects
disp('Step 1: Create video object')
ms = CreateMsForSessionsDir(parent_dir, analysis_time, spatial_downsampling);
ms.analysis_duration = 0;

%% 2 - Perform motion correction using NormCorre
disp('Step 2: Motion correction');

duration_tic = tic;
mkdir([ms.dirName filesep analysis_time]);

[Yf, ~] = ReadVideo(ms, 1);
ROISelectionFrame = Yf(:,:,10);
ms.ROIPosition = MarkROI(ms, ROISelectionFrame);
ms = myNormCorre(ms,isnonrigid);
ms.analysis_duration = ms.analysis_duration + toc(duration_tic);
save([ms.dirName filesep 'ms.mat'],'ms','-v7.3');

%% 3 - Perform CNMFE 
disp('Step 3: CNMFE');

duration_tic = tic;
ms = msRunCNMFE_large(ms);
ms.analysis_duration = ms.analysis_duration + toc(duration_tic);

if with_manual_intervention
    msRunManualIntervention;
end

duration_tic = tic;
msRunAfterIntervention;

msExtractSFPs(ms); % Extract spatial footprints for subsequent re-alignement

ms.analysis_duration = ms.analysis_duration + toc(duration_tic);

save([ms.dirName filesep 'ms.mat'],'ms','-v7.3');
disp(['Data analyzed in ' num2str(analysis_duration) 's']);
