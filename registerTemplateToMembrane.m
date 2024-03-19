function [u, v] = registerTemplateToMembrane(img, ProteinTemplate, varargin)
%REGISTERTEMPLATETOMEMBRANE  Register template to microarray membrane image
%
%  [U, V] = REGISTERTEMPLATETOMEMBRANE(I, T) will align template
%  coordinates to the microarray membrane image I. T should be a struct
%  containing the template data. T can be loaded from the MAT-files
%  provided by RnD. 
%
%  Currently the algorithm expects that the image is mostly aligned
%  correctly in portrait oritentation.

debugMode = false;
if ~isempty(varargin)
    if strcmpi(varargin{1}, 'debug')
        debugMode = true;
    end
end


%% Identify the reference spots in image

%Increase the contrast and resize the image to help imfindcircles work
%better
imgEnh = imadjust(img);
imgEnh = imresize(imgEnh, 4);

%Use the Hough transform to identify dark cicles in the image
[centers, radii] = imfindcircles(imgEnh, [7 15], 'ObjectPolarity', 'dark');

%Correct for rescale factor
centers = centers/4;

if debugMode

    %Plot location of circles
    figure;
    imshow(img)
    viscircles(centers, 2)
    title('Spots identified')

end

%Identify the calibration spots

%TODO: Determine orientation (e.g. portrait or landscape) - maybe using
%image size?. For now, we assume the membranes are portrait oriented.

%The top-left point will have the smallest sum, the bottom-right will have
%largest sum. 
sumCoords = sum(centers, 2);

[~, ind] = min(sumCoords);
imgTL = centers(ind, :);

[~, ind] = max(sumCoords);
imgBR = centers(ind, :);

%Top-right will have largest difference, bottom-left will have smallest
diffCoords = centers(:, 1) - centers(:, 2);

[~, ind] = max(diffCoords);
imgTR = centers(ind, :);

if debugMode

    %Plot location of spots to check

    figure;
    imshow(img)

    hold on
    plot(imgTL(1), imgTL(2), '.', ...
        imgBR(1), imgBR(2), 'x', ...
        imgTR(1), imgTR(2), 'o')
    hold off
    title('Image: . - TL, x - BR, o - TR', 'Interpreter', 'none');

end

%Combine into a single matrix for registration
imageCoords = [imgTL; imgBR; imgTR];

%% %Calculate the template parameters. 

% Note: I found the correct points by trial-and-error. Not ordered as I
% would have thought.
templateTL = ProteinTemplate.Points(:,ProteinTemplate.PositiveControlIndex(end - 1));
templateBR = ProteinTemplate.Points(:,ProteinTemplate.PositiveControlIndex(4));
templateTR = ProteinTemplate.Points(:,ProteinTemplate.PositiveControlIndex(1));

if debugMode

    figure;
    plot(ProteinTemplate.Points(1, :), ProteinTemplate.Points(2, :), 'o', ...
        templateTL(1), templateTL(2), '.', ...
        templateBR(1), templateBR(2), 'x', ...
        templateTR(1), templateTR(2), 'ro')

    title('Template: . - TL, x - BR, o - TR (red)', 'Interpreter', 'none');

end

%Combine into a single matrix for registration
templateCoords = [templateTL'; templateBR'; templateTR'];

%% Register the two sets of points


tform = fitgeotform2d(templateCoords, imageCoords, 'affine');
[u,v] = transformPointsForward(tform,ProteinTemplate.Points(1, :)',ProteinTemplate.Points(2, :)');

if debugMode

    figure;
    imshow(img, [])
    hold on
    plot(u, v, 'ro')
    hold off
    title('Registered template')

end