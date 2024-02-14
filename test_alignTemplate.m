clearvars
clc

%Read in template and image data
load('../data/RnD_Human_XL_Cytokine_ARY022B.mat')
img = imread('../data/cropped/contrast3.tif');

%%
%Pre-process image to enhance spots
imgEnh = imadjust(img);
imgEnh = imresize(imgEnh, 4);


%%
%Identify spots in image
[centers, radii, metric] = imfindcircles(imgEnh, [7 15], 'ObjectPolarity', 'dark');

imshow(imgEnh)
viscircles(centers, radii)

%%
imshow(img, [])
viscircles(centers/4, 2)

%Identify the calibration spots

%TODO: Use the centers to determine orientation (e.g. portrait or
%landscape)

%The top-left point will have the smallest sum, the bottom-right will have
%largest
sumCoords = sum(centers, 2);

[~, topLeftInd] = min(sumCoords);
[~, botRightInd] = max(sumCoords);

%Top-right will have largest difference, bottom-left will have smallest
diffCoords = centers(:, 1) - centers(:, 2);

[~, topRightInd] = max(diffCoords);
%[~, topRightInd] = min(diffCoords);


hold on
plot(centers(topLeftInd, 1), centers(topLeftInd, 2), '.', ...
    centers(botRightInd, 1), centers(botRightInd, 2), 'x', ...
    centers(topRightInd, 1), centers(topRightInd, 2), 'o')
hold off

%Get orientation and scale
vecDiffTLBR = centers(topLeftInd,:) - centers(botRightInd,:);

orientation = atan2(vecDiffTLBR(2), vecDiffTLBR(1));
distance = sqrt(sum(vecDiffTLBR .^2));

%Add the final matrix
imageCoords = [centers(topLeftInd, :);
    centers(botRightInd, :);
    centers(topRightInd, :)];
imageCoords = imageCoords/4;

%%
%Calculate the template parameters. I found the correct points by
%trial-and-error. Not ordered as I would have thought.
templateTL = ProteinTemplate.Points(:,ProteinTemplate.PositiveControlIndex(end - 1));
templateBR = ProteinTemplate.Points(:,ProteinTemplate.PositiveControlIndex(4));
templateTR = ProteinTemplate.Points(:,ProteinTemplate.PositiveControlIndex(1));

figure;
plot(ProteinTemplate.Points(1, :), ProteinTemplate.Points(2, :), 'o', ...
    templateTL(1), templateTL(2), 'bx', ...
    templateBR(1), templateBR(2), 'rx', ...
    templateTR(1), templateTR(2), 'ro')

templateCoords = [templateTL'; templateBR'; templateTR'];

%% Register the two points

tform = fitgeotform2d(templateCoords, imageCoords, 'affine');

%registeredTemplateCoords = [templateCoords'; ones(1, size(templateCoords, 1))] * tform.A;

%[u,v] = transformPointsForward(tform,templateCoords(:, 1),templateCoords(:, 2));

[u,v] = transformPointsForward(tform,ProteinTemplate.Points(1, :)',ProteinTemplate.Points(2, :)');

% figure;
% plot(templateCoords(:, 1), templateCoords(:, 2), 'ro', ...
%     u, v, 'o', ...
%     imageCoords(:, 1), imageCoords(:, 2), 'x')

figure;
imshow(img, [])
hold on
plot(u, v, 'ro')
hold off





