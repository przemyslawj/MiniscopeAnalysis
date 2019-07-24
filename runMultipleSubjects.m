parent_dir = '/mnt/DATA/Prez/ca_img/miniscope_habituation/2019-07-16/mv_caimg/';
parent_dir = '/mnt/DATA/Prez/cheeseboard/2019-07-habituation/2019-07-22/mv_caimg/';

%% Parameters
spatial_downsampling = 2; % (Recommended range: 2 - 4. Downsampling significantly increases computational speed, but verify it does not
isnonrigid = false; % If true, performs non-rigid registration (slower). If false, rigid alignment (faster).
with_manual_intervention = true;
analysis_time = strcat(date,'_', datestr(datetime('now'), 'HH-MM-SS'));

subjects = GetSubdirNames(parent_dir);
nsubjects = numel(subjects);

%% 1 - Create video objects
disp('Step 1: Create video objects')

msStructs = cell(nsubjects, 1);
for subject_i = 1:nsubjects
    subject = subjects{subject_i};
    ms = CreateMsForSessionsDir([parent_dir filesep subject filesep], ...
        analysis_time, spatial_downsampling);
    ms.analysis_duration = 0;
    ms.subject = subject;
    msStructs{subject_i} = ms;
end

%% 2 - Perform motion correction using NormCorre
disp('Step 2: Motion correction');

for subject_i = 1:nsubjects
    ms = msStructs{subject_i};
    [Yf, ~] = ReadVideo(ms, 1, [10 11]);
    ROISelectionFrame = Yf(:,:,1);
    ms.ROIPosition = MarkROI(ms, ROISelectionFrame);
    msStructs{subject_i} = ms;
end

for subject_i = 1:nsubjects
    ms = msStructs{subject_i};
    mkdir([ms.dirName filesep analysis_time]);

    duration_tic = tic;
    ms = myNormCorre(ms,isnonrigid);
    ms.analysis_duration = ms.analysis_duration + toc(duration_tic);
    save([ms.dirName filesep 'ms.mat'],'ms','-v7.3');
    msStructs{subject_i} = ms;
end

%% 3 - Perform CNMFE until intervention
disp('Step 3: CNMFE');

for subject_i = 1:nsubjects
    ms = msStructs{subject_i};
    load([ms.dirName filesep 'ms.mat']);
    disp(['Running CNMFE for: ' subjects{subject_i}]);
    duration_tic = tic;
    ms = msRunCNMFE_large(ms);
    ms.analysis_duration = ms.analysis_duration + toc(duration_tic);
    msStructs{subject_i} = ms;
    save([ms.dirName filesep 'ms.mat'],'ms','-v7.3');
end

%% 4 - Manual review of neurons
disp('Step 4: Review neurons');
if with_manual_intervention
    for subject_i = 1:nsubjects
        ms = msStructs{subject_i};
        load([ms.dirName filesep 'ms.mat']);
        msRunManualIntervention;
        ms.cnmfe_matfile = neuron.save_workspace();
        ms.step = 'after_review';
        save([ms.dirName filesep 'ms.mat'],'ms','-v7.3');
        msStructs{subject_i} = ms;
    end
end

%% 4 - Run more CNMFE iterations
disp('Step 5: CNMFE after neurons reviewed');
for subject_i = 1:nsubjects
    ms = msStructs{subject_i};
    load([ms.dirName filesep 'ms.mat']);
    load(ms.cnmfe_matfile);

    duration_tic = tic;
    msRunAfterIntervention;

    msExtractSFPs(ms); % Extract spatial footprints for subsequent re-alignement

    ms.analysis_duration = ms.analysis_duration + toc(duration_tic);
    ms.step = 'CNMFE_after_review';

    save([ms.dirName filesep 'ms.mat'],'ms','-v7.3');
    disp(['Data for ' subjects{subject_i} ' analyzed in ' num2str(ms.analysis_duration) 's']);
end
