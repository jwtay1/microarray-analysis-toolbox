clearvars
clc

fileDir = '../data/cropped';
files = {'contrast1.tif', 'contrast2.tif', 'contrast3.tif', 'contrast4.tif', 'contrast5.tif'};

%Measure intensities in different spots
%Spots are top left, top right, and bottom right
coords = {[12 19; 92 18; 93 223], ...
    [19 25; 99 25; 98 232], ...
    [14 24; 96 22; 101 228], ...
    [11 13; 93 15; 90 220], ...
    [13 19; 93 18; 97 223]};
% 
% %Hack
% midPtRefSpot = [12 19; 12 19; 12 19; 12 19];
% validationSpot = [12 27; 12 27; 12 27; 12 27];
% testSpot = [57 68; 57 68; 57 68; 57 68];

for iF = 1:numel(files)

    % %Use to find the mid point coordinate of each spot
    % I = imread(fullfile(fileDir, files{iF}));
    % imshow(I, [])
    % 
    % pause;

    I = double(imread(fullfile(fileDir, files{iF})));

    %Measure intensities
    currSpotInt = zeros(1, size(coords{iF}, 1));
    for iSpot = 1:size(coords{iF}, 1)

        currSpotInt(iSpot) = measureInt(I, coords{iF}(iSpot, :));
        
    end
    storeSpotInt(iF, :) = currSpotInt;


    % if iF == 1
    % 
    %     %Use image 1 as the reference
    %     refInt = measureInt(I, midPtRefSpot(iF, :));
    % 
    % end
    % 
    % %Normalize the images
    % Iref = measureInt(I, midPtRefSpot(iF, :));
    % normImg = (I ./ Iref) * refInt;
    % 
    % %Measure the new spot intensities
    % Iref_norm(iF) = measureInt(normImg, midPtRefSpot(iF, :));
    % Iref_org(iF) = measureInt(I, midPtRefSpot(iF, :));
    % 
    % Ivalidation_norm(iF) = measureInt(normImg, validationSpot(iF, :));
    % Ivalidation_org(iF) = measureInt(I, validationSpot(iF, :));
    % 
    % Itest_norm(iF) = measureInt(normImg, testSpot(iF, :));
    % Itest_org(iF) = measureInt(I, testSpot(iF, :));

    %imwrite(normImg, ['normalized', int2str(iF), '.tif'], 'Compression', 'none');
    
end

%Calculate variation
for ii = 1:size(storeSpotInt, 1)

    variation(ii, :) = storeSpotInt(ii, :) ./ storeSpotInt(ii, 1);

end


%%
function meanInt = measureInt(I, pt)

meanInt = mean(I((pt(2) - 2):(pt(2) + 2),...
    (pt(1) - 2):(pt(1) + 2)), 'all');

end
