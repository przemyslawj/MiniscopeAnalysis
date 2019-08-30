function [ms] = CreateMsForSessionsDir(parent_dir, analysis_time, ...
    spatial_downsampling)

session_dirs = GetSubdirNames(parent_dir);
ms_files = {};
for i = 1:numel(session_dirs)
    if startsWith(session_dirs{i}, 'Session')
        session_dir = [parent_dir filesep session_dirs{i}];
        timestamp_dir = GetSubdirNames(session_dir);
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

if ms.numFiles < 1
    error(['No files found in dir ', parent_dir])
end

end

