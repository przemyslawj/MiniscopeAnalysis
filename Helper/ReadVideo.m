function [Yf, fpath] = ReadVideo(ms, video_i, frame_range)
fpath = [ms.vidObj{1, video_i}.Path filesep ms.vidObj{1, video_i}.Name];

if nargin < 3
    Yf = read_file(fpath);
else
    Yf = read_file(fpath, frame_range(1), frame_range(2) - frame_range(1) + 1);
end
Yf = single(Yf);
Yf = downsample_data(Yf,'space',1,ms.ds,1);
end
