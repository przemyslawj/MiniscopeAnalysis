parent_dir = '/mnt/DATA/Prez/ca_img/tmp/F/2017-10-31';
parent_dir = '/mnt/DATA/Prez/ca_img/tmp/1BR'
parent_dir = '/mnt/DATA/Prez/cheeseboard/2019-02-learning/2019-02-24/mv_caimg/1BR';

%% Parameters
spatial_downsampling = 2; % (Recommended range: 2 - 4. Downsampling significantly increases computational speed, but verify it does not
isnonrigid = false; % If true, performs non-rigid registration (slower). If false, rigid alignment (faster).
analyse_behavior = false;

% Generate timestamp to save analysis
script_start = tic;
analysis_time = strcat(date,'_', datestr(datetime('now'), 'HH-MM-SS'));

%% 1 - Create video objects
disp('Step 1: Create video object')

session_dirs = getsubdirnames(parent_dir);
ms_files = {};
for i = 1:numel(session_dirs)
    if startsWith(session_dirs{i}, 'Session')
        session_dir = [parent_dir filesep session_dirs{i}];
        timestamp_dir = getsubdirnames(session_dir);
        videos_path = [session_dir filesep timestamp_dir{1}];
        fprintf('Adding avi dir: %s\n', videos_path)
        new_ms = msGenerateVideoObj(videos_path, 'msCam');
        ms_files = [ms_files new_ms];
    end
end

ms = mergeMsStructs(ms_files);
ms.analysis_time = analysis_time;
ms.ds = spatial_downsampling;
ms.dirName = parent_dir;

%% 2 - Perform motion correction using NormCorre
mkdir([ms.dirName filesep analysis_time]);
save([ms.dirName filesep 'ms.mat'],'ms');
disp('Step 2: Motion correction');
ms = myNormCorre(ms,isnonrigid);

%% 3 - Perform CNMFE 
disp('Step 3: CNMFE');
ms = msRunCNMFE_large(ms);
msExtractSFPs(ms); % Extract spatial footprints for subsequent re-alignement

analysis_duration = toc(script_start);
ms.analysis_duration = analysis_duration;

save([ms.dirName filesep 'ms.mat'],'ms','-v7.3');
disp(['Data analyzed in ' num2str(analysis_duration) 's']);

%% Helper functions

function subdirNames = getsubdirnames(rootDir)
    subdirs = dir(rootDir);
    subdirNames = { subdirs([subdirs.isdir]).name };
    subdirNames = subdirNames(3:end);
end


