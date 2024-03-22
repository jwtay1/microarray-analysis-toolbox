baseDir = 'D:\Documents\OneDrive - UCB-O365\Shared\Share with Lynch Lab\Oncology Antibody Array';

templateFN = [baseDir, '\data\RnD_HumanXLOncology-ARY026.mat'];

imgFolders = {[baseDir, '\data\REP 1\cropped'], ...
    [baseDir, '\data\Rep 2\cropped'], ...
    [baseDir, '\data\Rep 3\cropped']};

outputFolder = [baseDir, '\processed\20240319_2x2'];

data = measureArray(templateFN, imgFolders, outputFolder, 2);

