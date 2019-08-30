function [position] = MarkROI(ms, frame)
    bound = 80 / 2/ ms.ds;
    ROIsize = [size(frame,1) - bound, size(frame,2) - bound];
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    imagesc(frame); axis image; colormap gray;
    h = imrect(gca,[bound,bound,ROIsize(2),ROIsize(1)]);

    suptitle({'Position the rectangles to select the best image region' ; 'Choose approx. the same area in every session' ; 'Confirm with double click on rectangles (left to right)'})
    position = wait(h);
    position(4) = position(2) + position(4);
    position(3) = position(1) + position(3);
    position = round(position);
    close(f);
end
