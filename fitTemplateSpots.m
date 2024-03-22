function fittedSpotData = fitTemplateSpots(img, u, v, varargin)
%FITTEMPLATESPOTS  Fit a Gaussian to spots
%
%  F = FITTEMPLATESPOTS(I, U, V) refines the spot positions by fitting the
%  spots to a Gaussian profile. I is the input image, U and V should be the
%  approximate position of the spots, as provided by the template
%  registration code. F is a matrix of the fitted parameters: [amplitude,
%  xoffset, yoffset, width, background, r-squared].

%Parse optional input argument
if isempty(varargin)
    debug = false;
end

%Pre-processing
szFit = 3;
img = double(img);

avgBg = median(img, 'all');
opts = optimset('Display','off');

%Initialize the output matrix - there are 5 fitted parameters + one
%r-squared value
fittedSpotData = zeros(numel(u), 6);

%Declare coordinates for fitting
xx = -szFit:szFit;
[xx, yy] = meshgrid(xx, xx);

%Round the initial centroid position
u = round(u);
v = round(v);

for ii = 1:numel(u)

    %Crop the image to be around the initial centroid position
    imgCrop = img((v(ii) - szFit):(v(ii) + szFit), ...
        (u(ii) - szFit):(u(ii) + szFit));

    %Generate the initial guess
    guessParams = [max(imgCrop, [], 'all'), 0, 0, 2, avgBg];  

    %Fit the image to a 2d Gaussian
    [fitParams, resnorm] = lsqcurvefit(@gaussFunc, guessParams, cat(3, xx, yy), imgCrop,...
        [0, -3, -3, 1, 0], [Inf, 3, 3, 4, 65535], opts);

    if debug
        zz = gaussFunc(fitParams, cat(3, xx, yy));
        zzGuess = gaussFunc(guessParams, cat(3, xx, yy));
        surf(xx, yy, imgCrop)
        hold on
        plot3(xx, yy, zz, 'ro')
        hold off
    end

    %Calculate r-squared value
    ssTotal = sum(sum( (imgCrop - mean(imgCrop, 'all')) .^2));
    Rsq = 1 - (resnorm/ssTotal);

    %Store data
    fittedSpotData(ii, :) = [fitParams, Rsq];

end

end