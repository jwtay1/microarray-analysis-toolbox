clearvars
close all
clc

templateFN = '../data/RnD_Human_XL_Cytokine_ARY022B.mat';

imgFolders = {'C:\Users\jianw\OneDrive - UCB-O365\Shared\Share with Lynch Lab\data\ESV03 (spotted array)\cropped', ...
    'C:\Users\jianw\OneDrive - UCB-O365\Shared\Share with Lynch Lab\data\ESV06 (spotted array)\cropped', ...
    'C:\Users\jianw\OneDrive - UCB-O365\Shared\Share with Lynch Lab\data\ESV07 (spotted array)\cropped', ...
    'C:\Users\jianw\OneDrive - UCB-O365\Shared\Share with Lynch Lab\data\ESV09 (spotted array)\cropped', ...
    'C:\Users\jianw\OneDrive - UCB-O365\Shared\Share with Lynch Lab\data\ESV10 (spotted array)\cropped'};

%Specify location to store output files
outputFolder = 'C:\Users\jianw\OneDrive - UCB-O365\Shared\Share with Lynch Lab\processed\20240214';

%% Process images in folders

load(templateFN)  %Load the ProteinTemplate data

%Make output folder if it doesn't already exist
if ~exist(fullfile(outputFolder), 'dir')
            mkdir(outputFolder);
end

%Initialize an empty struct for data storage
storeData = [];

for iFolder = 1:numel(imgFolders)

    %Get image files in folder
    imgFiles = dir(fullfile(imgFolders{iFolder}, '*.tif'));

    for iFile = 1:numel(imgFiles)

        %Read in image
        imageFN = fullfile(imgFiles(iFile).folder, imgFiles(iFile).name);
        I = imread(imageFN);

        %Register the image
        [u, v] = registerTemplateToMembrane(I, ProteinTemplate);

        %Measure image data. As a first pass, measure the intensity within
        %a 2px radius of center.
        storeInt = zeros(1, numel(u));

        for iPt = 1:numel(u)

            storeInt(iPt) = mean(I((round(v(iPt)) - 2):(round(v(iPt)) + 2), ...
                (round(u(iPt)) - 2):(round(u(iPt)) + 2)), 'all');

        end

        %---Save output files---

        %Make and save figure for future reference
        h = figure;
        imshow(I, [])
        hold on
        plot(u, v, 'ro')
        hold off
        title('Registered template')

        %Create output image filename

        [fpath, fname, fext] = fileparts(imageFN);

        %Create a in the output folder with the same name as the original
        %data folder
        [fpath2, folderName] = fileparts(fpath);

        if strcmpi(folderName, 'cropped')
            %If the folder is named cropped, go up one more level
            [~, folderName] = fileparts(fpath2);
        end

        if ~exist(fullfile(outputFolder, folderName), 'dir')
            mkdir(fullfile(outputFolder, folderName));
        end

        saveas(h, fullfile(outputFolder, folderName, [fname, '.png']), 'png');
        close(h)
        
        dataInd = numel(storeData) + 1;
        storeData(dataInd).filename = imageFN;
        storeData(dataInd).intensities = storeInt;

        clearvars storeInt

    end
end

%% Normalize the data

refPtInd = ProteinTemplate.PositiveControlIndex(end - 1);

for iData = 1:numel(storeData)

    if iData == 1

        refInt = storeData(iData).intensities(refPtInd);

    end

    storeData(iData).normIntensities = (storeData(iData).intensities ./ storeData(iData).intensities(refPtInd)) * refInt;

end

save(fullfile(outputFolder, 'data.mat'), 'storeData', 'imgFolders', 'templateFN');

%% Export the data to CSV

fid = fopen(fullfile(outputFolder, 'rawInt.csv'), 'w');

%Write headers
fprintf(fid, 'Filename');

for iP = 1:numel(ProteinTemplate.ProteinLabels)

    fprintf(fid, ', %s 1, %s 2', ProteinTemplate.ProteinLabels{iP}, ProteinTemplate.ProteinLabels{iP});

end

fprintf(fid, '\n');

for iData = 1:numel(storeData)

    fprintf(fid, '%s', storeData(iData).filename);

    for iDataPoint = 1:numel(storeData(iData).intensities)
        fprintf(fid, ',%.3f', storeData(iData).intensities(iDataPoint));
    end

    fprintf(fid, '\n');

end

fclose(fid);

%Normalized data file

fid = fopen(fullfile(outputFolder, 'normInt.csv'), 'w');

%Write headers
fprintf(fid, 'Filename');

for iP = 1:numel(ProteinTemplate.ProteinLabels)

    fprintf(fid, ', %s 1, %s 2', ProteinTemplate.ProteinLabels{iP}, ProteinTemplate.ProteinLabels{iP});

end

fprintf(fid, '\n');

for iData = 1:numel(storeData)

    fprintf(fid, '%s', storeData(iData).filename);

    for iDataPoint = 1:numel(storeData(iData).normIntensities)
        fprintf(fid, ',%.3f', storeData(iData).normIntensities(iDataPoint));
    end

    fprintf(fid, '\n');

end

fclose(fid);



% %%
% 
% plot(ProteinTemplate.Points(1, :), ProteinTemplate.Points(2, :), 'o')
% hold on
% plot(ProteinTemplate.Points(1, [5 6]), ProteinTemplate.Points(2, [5 6]), 'x')
% hold off












