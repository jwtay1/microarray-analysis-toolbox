baseDir = 'D:\Documents\OneDrive - UCB-O365\Shared\Share with Lynch Lab\Oncology Antibody Array';

templateFN = [baseDir, '\data\RnD_HumanXLOncology-ARY026.mat'];

imgFolders = {[baseDir, '\data\REP 1\cropped'], ...
    [baseDir, '\data\Rep 2\cropped'], ...
    [baseDir, '\data\Rep 3\cropped']};

outputFolder = [baseDir, '\processed\20240319_2x2'];

data = measureArray(templateFN, imgFolders, outputFolder, 2);


%%
load(templateFN)






%%
data3raw = data(3).intensities;
data4raw = data(4).intensities;

plot(data3raw)
hold on
plot(data4raw)
hold off

%Normalize using intensity of all spots
% avg = mean(data3raw([ProteinTemplate.PositiveControlIndex]), 'omitnan');
% avg4 = mean(data4raw([ProteinTemplate.PositiveControlIndex]), 'omitnan');
% 
% data3norm = data3raw ./ avg;
% data4norm = data4raw ./ avg4;

% data3norm = data3raw ./ ((data3raw(173) + data3raw(174))/2);
% data4norm = data4raw ./ ((data4raw(173) + data4raw(174))/2);

%% Try to fit a plane

positiveControlIndex = ProteinTemplate.PositiveControlIndex;

refData = data3raw(positiveControlIndex);

A = [data(3).registeredSpots(positiveControlIndex, :), ones(numel(ProteinTemplate.PositiveControlIndex), 1)];      

coeffs = pinv(A) * refData';

%Calculate the intensity surface
intSurf = (coeffs(1) .* data(3).registeredSpots(:, 1)) + (coeffs(2) .* data(3).registeredSpots(:, 2)) + ...
    ones(size(data(3).registeredSpots, 1), 1);

plot3(data(3).registeredSpots(:, 1), data(3).registeredSpots(:, 2), intSurf)
hold on
plot3(data(3).registeredSpots(:, 1), data(3).registeredSpots(:, 2), data(3).RawIntensities, 'ro')
hold off

data3norm = data3raw ./ intSurf;

plot(data3norm)
hold on
plot(data4norm)
hold off

%Calculate the average of the two spots
for ii = 1:(numel(data3norm)/2)

    m3data(ii) = (data3norm((2 * (ii - 1)) + 1) + data3norm(2 * ii))/2;
    m4data(ii) = (data4norm((2 * (ii - 1)) + 1) + data4norm(2 * ii))/2;

end

plot(m3data)
hold on
plot(m4data)
hold off

storeChange = (data4norm./data3norm);
bar(storeChange)
%%
%Try to plot
figure(1)
I = imread(data(3).filename);
imshow(I, [])
hold on
for ii = 1:numel(storeChange)
    if isnan(storeChange(ii))
        continue
    else
        if storeChange(ii) < 0.8
            plot(data(3).registeredSpots(ii, 1), data(3).registeredSpots(ii, 2), 'ro')
        elseif storeChange(ii) > 1.2
            plot(data(3).registeredSpots(ii, 1), data(3).registeredSpots(ii, 2), 'g.')
        end
    end

end
hold off

figure(2)
I2 = imread(data(4).filename);
imshow(I2)

%Plot a change heatmap
ProteinTemplate.ProteinLabels{3}
ProteinTemplate.ProteinLabels{7}
ProteinTemplate.ProteinLabels{10}
ProteinTemplate.ProteinLabels{22}

