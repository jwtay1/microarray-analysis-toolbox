clearvars
clc

fileDir = '../data';
files = {'contrast1.tif', 'contrast1_2.tif', 'contrast1_3.tif', 'contrast1_4.tif'};

%Hack
midPtRefSpot = [12 19; 12 19; 12 19; 12 19];
validationSpot = [12 27; 12 27; 12 27; 12 27];
testSpot = [57 68; 57 68; 57 68; 57 68];

for iF = 1:numel(files)

    % %Use to find the mid point coordinate of each spot
    % I = imread(fullfile(fileDir, files{iF}));
    % imshow(I, [])
    % 
    % pause;

    I = double(imread(fullfile(fileDir, files{iF})));

    if iF == 1

        %Use image 1 as the reference
        refInt = measureInt(I, midPtRefSpot(iF, :));

    end

    %Normalize the images
    Iref = measureInt(I, midPtRefSpot(iF, :));
    normImg = (I ./ Iref) * refInt;

    %Measure the new spot intensities
    Iref_norm(iF) = measureInt(normImg, midPtRefSpot(iF, :));
    Iref_org(iF) = measureInt(I, midPtRefSpot(iF, :));

    Ivalidation_norm(iF) = measureInt(normImg, validationSpot(iF, :));
    Ivalidation_org(iF) = measureInt(I, validationSpot(iF, :));

    Itest_norm(iF) = measureInt(normImg, testSpot(iF, :));
    Itest_org(iF) = measureInt(I, testSpot(iF, :));

    %imwrite(normImg, ['normalized', int2str(iF), '.tif'], 'Compression', 'none');
    
end


%%
figure(1)
plotyy(1:4, Iref_org, 1:4, Iref_norm)
title('Reference spot')

figure(2)
plotyy(1:4, Ivalidation_org, 1:4, Ivalidation_norm)
title('Validation spot');

figure(3)
plotyy(1:4, Itest_org, 1:4, Itest_norm)
title('Test spot');

%%
function meanInt = measureInt(I, pt)

meanInt = mean(I((pt(2) - 2):(pt(2) + 2),...
    (pt(1) - 2):(pt(1) + 2)), 'all');

end
