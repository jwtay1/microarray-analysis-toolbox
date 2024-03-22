function varargout = measureArray(templateFN, imgFolders, outputFolder, varargin)
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

if ~isempty(varargin)
    avgSize = varargin{1};
else
    avgSize = 2;
end


%Load the ProteinTemplate data
load(templateFN, 'ProteinTemplate')  

%Make output folder if it doesn't already exist
if ~exist(fullfile(outputFolder), 'dir')
            mkdir(outputFolder);
end

for iFolder = 1%:numel(imgFolders)

    %Get image files in folder
    imgFiles = dir(fullfile(imgFolders{iFolder}, '*.tif'));

    for iFile = 1:numel(imgFiles)

        %Read in image
        imageFN = fullfile(imgFiles(iFile).folder, imgFiles(iFile).name);
        I = imread(imageFN);

        %Invert the image
        I = imcomplement(I);

        %Register the template to the image
        [u, v] = registerTemplateToMembrane(I, ProteinTemplate);

        %Fine-tune the fitted positions
        fittedParameters = fitTemplateSpots(I, u, v);

        %Calculate the fine-tuned centroid positions
        uFT = u - fittedParameters(:, 2);
        vFT = v - fittedParameters(:, 3);

        %Measure image data. As a first pass, measure the intensity within
        %a 2px radius of center.
        storeInt = zeros(numel(uFT), 1);

        for iPt = 1:numel(uFT)

            storeInt(iPt) = mean(I((round(vFT(iPt)) - avgSize):(round(vFT(iPt)) + avgSize), ...
                (round(uFT(iPt)) - avgSize):(round(uFT(iPt)) + avgSize)), 'all');

            % imshow(I((round(v(iPt)) - avgSize):(round(v(iPt)) + avgSize), ...
            %     (round(u(iPt)) - avgSize):(round(u(iPt)) + avgSize)))
            % pause

        end

        %Normalize the spot intensities
        refPtInd = ProteinTemplate.PositiveControlIndex(end - 1);

        normIntensities = (storeInt ./ storeInt(refPtInd));
        normIntensitiesBgCorrected = (storeInt - fittedParameters(:,5))./(storeInt(refPtInd) - fittedParameters(refPtInd, 5));

        %Generate the output storage struct
        if ~exist('storeData', 'var')
            dataInd = 1;
        else
            dataInd = numel(storeData) + 1;
        end

        storeData(dataInd).Filename = imageFN;
        storeData(dataInd).FittedData = fittedParameters;

        %Calculate derived data
        storeData(dataInd).MeanIntensityRaw = storeInt;
        storeData(dataInd).MeanIntensityCorrectedRaw = storeInt - fittedParameters(:, 5);

        storeData(dataInd).MeanIntensity = normIntensities;
        storeData(dataInd).MeanIntensityCorrected = normIntensitiesBgCorrected;


        %--- Save image files ---

        %Create output image filename
        [fpath, fname, ~] = fileparts(imageFN);

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

        %Make and save figure for future reference
        h = figure;
        imshow(I, [])
        hold on
        plot(uFT, vFT, 'r.')
        hold off
        title('Registered template')
        saveas(h, fullfile(outputFolder, folderName, [fname, '.png']), 'png');
        close(h)

        %Save the inverted image
        imwrite(I, [fname, '.tif'], 'Compression', 'none')

        clearvars storeInt

    end
end

save(fullfile(outputFolder, 'spotData.mat'), 'storeData', 'imgFolders', 'templateFN');

%% Export the data to CSV
% 
% %Filter bad fits
% idxBadFit = find([spotData.Rsq] < 0.95);
% 
% for ii = idxBadFit
%     spotData(ii).Intensity = NaN;
%     spotData(ii).Center = [NaN, NaN];
% end
%%

fid = fopen(fullfile(outputFolder, 'rawInt.csv'), 'w');

%Write headers
fprintf(fid, 'Filename');

for iP = 1:numel(ProteinTemplate.ProteinLabels)

    fprintf(fid, ', %s 1, %s 2', ProteinTemplate.ProteinLabels{iP}, ProteinTemplate.ProteinLabels{iP});

end

fprintf(fid, '\n');

for iData = 1:numel(storeData)

    fprintf(fid, '%s', storeData(iData).Filename);

    for iDataPoint = 1:numel(storeData(iData).MeanIntensityRaw)
        fprintf(fid, ',%.3f', storeData(iData).MeanIntensityRaw(iDataPoint));
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

    fprintf(fid, '%s', storeData(iData).Filename);

    for iDataPoint = 1:numel(storeData(iData).MeanIntensityCorrected)
        fprintf(fid, ',%.3f', storeData(iData).MeanIntensityCorrected(iDataPoint));
    end

    fprintf(fid, '\n');

end

fclose(fid);

varargout{1} = storeData;

end