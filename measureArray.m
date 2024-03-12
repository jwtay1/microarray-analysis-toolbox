function measureArray(templateFN, imgFolders, outputFolder)
%MEASUREARRAY  Measure intensity from microarray
%
%  MEASUREARRAY(TEMPLATE, IMGDIR, OUTPUTDIR) processes the microarray
%  images stored in the directory IMGDIR. The microarray images are aligned
%  to the defined template file. The resulting intensities are exported as
%  CSVs to OUTPUTDIR.
%
%  TEMPLATE is a struct that contains information about the microarray, as
%  supplied by RnD. The struct should be named ProteinTemplate and have the
%  following fields:
%     - ProteinLabels: Cell array of protein names.
%     - Points: 2xN double containing relative coordinates of each well.
%       Note that N should be double (2x) the number of proteins.
%     - PositiveControlIndex - index of the positive control wells
%     - NegativeControlIndex - index of the negative control wells (usually
%                              bottom left)

%  This toolbox was written by Dr. Jian Wei Tay (jian.tay@colorado.edu) at
%  the BioFrontiers Institute, University of Colorado Boulder.


%Load the ProteinTemplate data
load(templateFN, 'ProteinTemplate')  

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



end