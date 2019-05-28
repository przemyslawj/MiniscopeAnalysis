function ms = mergeMsStructs(ms_list)

    ms = struct();
    if isempty(ms_list)    
        return
    end
    
    ms.dirName = ms_list{1};
    ms.maxFramesPerFile = ms_list{1}.maxFramesPerFile;
    ms.height = ms_list{1}.height;
    ms.width = ms_list{1}.width;
    ms.Experiment = ms_list{1}.Experiment;
    
    ms.numFiles = 0;
    ms.numFrames = 0;
    ms.vidNum = [];
    ms.frameNum = [];
    ms.vidObj = {};
    ms.time = [];
    
    ms.sessionLengths = {};
     
    for i = 1 : numel(ms_list)
        m = ms_list{i};

        ms.vidNum = [ms.vidNum (ms.numFiles + m.vidNum)];
        ms.frameNum = [ms.frameNum m.frameNum];
        ms.vidObj = [ms.vidObj m.vidObj];
        ms.time = [ms.time; m.time];
        
        ms.numFiles = ms.numFiles + m.numFiles;
        ms.numFrames = ms.numFrames + m.numFrames;
        ms.sessionLengths{i} = m.numFrames;
    end
end
