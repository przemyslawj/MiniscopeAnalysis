function subdirNames = GetSubdirNames(rootDir)
    subdirs = dir(rootDir);
    subdirNames = { subdirs([subdirs.isdir]).name };
    subdirNames = subdirNames(3:end);
end

