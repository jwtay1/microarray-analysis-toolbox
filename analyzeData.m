clearvars
clc

file = 'D:\Documents\OneDrive - UCB-O365\Shared\Share with Lynch Lab\Oncology Antibody Array\processed\20240319_2x2\spotData.mat';

load(file)

figure(1)
for ii = 1:4
    
    subplot(2, 2, 1)
    plot(storeData(ii).MeanIntensityRaw)
    hold on

    subplot(2, 2, 2)
    plot(storeData(ii).MeanIntensityCorrectedRaw)
    hold on

    subplot(2, 2, 3)
    plot(storeData(ii).MeanIntensity)
    hold on

    subplot(2, 2, 4)
    plot(storeData(ii).MeanIntensityCorrected)
    hold on

end

subplot(2, 2, 1)
title('Mean Intensity Raw')
hold off
subplot(2, 2, 2)
title('Mean Intensity Raw - BG corrected')
hold off
subplot(2, 2, 3)
title('Mean Intensity Normalized')
hold off
subplot(2, 2, 4)
title('Mean Intensity Normalized - BG corrected')
hold off


%% Calculate average of the two wells

figure(2)
for ii = 1:4    
    for jj = 1:(numel(storeData(ii).MeanIntensity)/2)

        storeData(ii).AverageSpotIntensity(jj) = mean(...
            [storeData(ii).MeanIntensityCorrected((jj - 1) * 2 + 1), storeData(ii).MeanIntensityCorrected(jj * 2)]);

    end   

    plot(storeData(ii).AverageSpotIntensity)
    hold on
end
hold off

%%

cutoff = 0.05;

%Calculate differences - but only if data has a significant signal
%datasetDifference1vs2 = (storeData(2).AverageSpotIntensity - storeData(1).AverageSpotIntensity) ./ storeData(1).AverageSpotIntensity;
datasetDifference1vs2 = (storeData(2).AverageSpotIntensity./storeData(1).AverageSpotIntensity);
datasetDifference1vs2 = datasetDifference1vs2 * 100;
datasetDifference1vs2(storeData(2).AverageSpotIntensity < cutoff) = 0;

%datasetDifference3vs4 = (storeData(4).AverageSpotIntensity - storeData(3).AverageSpotIntensity) ./ storeData(3).AverageSpotIntensity;
datasetDifference3vs4 = (storeData(4).AverageSpotIntensity ./ storeData(3).AverageSpotIntensity);
datasetDifference3vs4 = datasetDifference3vs4 * 100;
datasetDifference3vs4(storeData(4).AverageSpotIntensity < cutoff) = 0;

load('D:\Documents\OneDrive - UCB-O365\Shared\Share with Lynch Lab\Oncology Antibody Array\data\RnD_HumanXLOncology-ARY026.mat');

figure(3)
bar(datasetDifference1vs2)
ylabel('% Ratio')

%Only show labels of important changes
idx = find(datasetDifference1vs2 ~= 0);

xticks(idx)
xticklabels({ProteinTemplate.ProteinLabels{idx}})
xtickangle(45)
title('Difference 1 vs 2')

% xticks(1:numel(datasetDifference1vs2))
% xticklabels(ProteinTemplate.ProteinLabels)
% xtickangle(45)
% title('Difference 1 vs 2')

figure(4)
bar(datasetDifference3vs4)
title('Difference 3 vs 4')
ylabel('% Ratio')

%Only show labels of important changes
idx = find(datasetDifference3vs4 ~= 0);

xticks(idx)
xticklabels({ProteinTemplate.ProteinLabels{idx}})
xtickangle(45)


% xticks(1:numel(datasetDifference3vs4))
% xticklabels(ProteinTemplate.ProteinLabels)
% xtickangle(45)

ProteinTemplate.ProteinLabels{41}
ProteinTemplate.ProteinLabels{54}
ProteinTemplate.ProteinLabels{65}
ProteinTemplate.ProteinLabels{78}










