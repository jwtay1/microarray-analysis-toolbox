file = '../data/09.30.22_SV_4x4_10min_1_CONTRAST.tif';

I= imread(file);

imshow(I)

%%
Iout = imcrop;
imwrite(Iout, '../data/contrast5.tif', 'Compression', 'none')