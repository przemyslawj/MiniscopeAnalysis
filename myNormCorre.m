function ms = myNormCorre(ms,isnonrigid)
% Performs fast, rigid registration (option for non-rigid also available).
% Relies on NormCorre (Paninski lab). Rigid registration works fine for
% large lens (1-2mm) GRIN lenses, while non-rigid might work better for
% smaller lenses. Ideally you want to compare both on a small sample before
% choosing one method or the other.
% Original script by Eftychios Pnevmatikakis, edited by Guillaume Etter
% Modified by Prez Jarzebowski


%warning off all

%% Filtering parameters
gSig = 7/ms.ds;
gSiz = 17/ms.ds;
psf = fspecial('gaussian', round(2*gSiz), gSig);
ind_nonzero = (psf(:)>=max(psf(:,1)));
psf = psf-mean(psf(ind_nonzero));
psf(~ind_nonzero) = 0;


template = [];

registeredGreyVid = VideoWriter([ms.dirName filesep ms.analysis_time filesep 'msvideo_gray.avi'],'Grayscale AVI');
registeredVid = VideoWriter([ms.dirName filesep ms.analysis_time filesep 'msvideo.avi'],'Grayscale AVI');
open(registeredVid);
open(registeredGreyVid);

ms.shifts = [];
ms.meanFrame = [];
position = [];

for video_i = 1:ms.numFiles
    name = [ms.vidObj{1, video_i}.Path filesep ms.vidObj{1, video_i}.Name];
    disp(['Registration on: ' name]);
    
    % read data and convert to single
    Yf = read_file(name);
    Yf = single(Yf);
    Yf = downsample_data(Yf,'space',1,ms.ds,1);
    
    if isempty(position)
        bound = 80 / 2/ ms.ds;
        ROIsize = [size(Yf,1) - bound, size(Yf,2) - bound];
        f = figure('units','normalized','outerposition',[0 0 1 1]);
        imagesc(Yf(:,:,10)); axis image; colormap gray;
        h = imrect(gca,[bound,bound,ROIsize(2),ROIsize(1)]);

        suptitle({'Position the rectangles to select the best image region' ; 'Choose approx. the same area in every session' ; 'Confirm with double click on rectangles (left to right)'})
        position = wait(h);
        position(4) = position(2) + position(4);
        position(3) = position(1) + position(3);
        position = round(position);
        close(f);
    end
    
    Y = imfilter(Yf, psf, 'symmetric');
    Y_cropped = Y(position(2):position(4), position(1):position(3), :);
    [d1, d2, T] = size(Y_cropped);
      
    % Setting registration parameters (rigid vs non-rigid)
    if isnonrigid
        disp('Non-rigid motion correction...');
        options = NoRMCorreSetParms('d1',d1,'d2',d2,'bin_width',50, ...
            'grid_size',[128,128]*2,'mot_uf',4,'correct_bidir',false, ...
            'overlap_pre',32,'overlap_post',32,'max_shift',20);
    else
        disp('Rigid motion correction...');
        options = NoRMCorreSetParms('d1',d1,'d2',d2,'bin_width',100,...
            'grid_size',[64,64],...
            'max_shift',10,'iter',1,'correct_bidir',false);
    end
    
    %% register using the high pass filtered data and apply shifts to original data
    if isempty(template)
        [M1,shifts1,template] = normcorre(Y_cropped, options); 
    else
        [M1,shifts1,template] = normcorre(Y_cropped,options,template); % register filtered data
    end
    
    Mr = apply_shifts(Yf,shifts1,options,double(position(2)),double(position(1))); 
    M1_scaled = M1 - min(M1(:));
    M1_scaled = M1_scaled * 250 / max(M1_scaled(:));
    writeVideo(registeredGreyVid,uint8(M1_scaled));
    writeVideo(registeredVid,uint8(Mr));
    
    %% compute metrics
    [cY,mY,vY] = motion_metrics(Y_cropped, options.max_shift);
    [cYf,mYf,vYf] = motion_metrics(Yf,options.max_shift); 
    [cM1,mM1,vM1] = motion_metrics(M1,options.max_shift);
    [cM1f,mM1f,vM1f] = motion_metrics(Mr,options.max_shift);

% Plotting shifts doesn't work when grid_size specified
%     shifts_r = squeeze(cat(3,shifts1(:).shifts));
%     figure;
%     subplot(311); plot(shifts_r);
%         title('Rigid shifts','fontsize',14,'fontweight','bold');
%         legend('y-shifts','x-shifts');
%     subplot(312); plot(1:T,cY,1:T,cM1);
%         title('Correlation coefficients on filtered movie','fontsize',14,'fontweight','bold');
%         legend('raw','rigid');
%     subplot(313); plot(1:T,cYf,1:T,cM1f);
%         title('Correlation coefficients on full movie','fontsize',14,'fontweight','bold');
%         legend('raw','rigid');
    
    if video_i == 1
        ms.meanFrame = mM1f;
    else
        ms.meanFrame = (ms.meanFrame + mM1f)./2;
    end
    corr_gain = cYf./cM1f*100;
    
    ms.shifts{video_i} = shifts1;
       
end

close(registeredVid);
close(registeredGreyVid);

end
