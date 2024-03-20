function fittedSpotData = fitTemplateSpots(img, u, v, varargin)

if isempty(varargin)
    debug = false;
end

szFit = 3;
img = double(imcomplement(img));

avgBg = median(img, 'all');
opts = optimset('Display','off');

xx = -szFit:szFit;
[xx, yy] = meshgrid(xx, xx);

u = round(u);
v = round(v);

for ii = 1:numel(u)

    imgCrop = img((v(ii) - szFit):(v(ii) + szFit), ...
        (u(ii) - szFit):(u(ii) + szFit));

    %Check if worth fitting
    if max(imgCrop)


    end

    guessParams = [max(imgCrop, [], 'all'), 0, 0, 2, avgBg];  

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

    ssTotal = sum(sum( (imgCrop - mean(imgCrop, 'all')) .^2));
    Rsq = 1 - (resnorm/ssTotal);

    %Store data
    fittedSpotData(ii).Center = [u(ii) + fitParams(2), v(ii) + fitParams(3)];
    fittedSpotData(ii).Background = fitParams(5);
    fittedSpotData(ii).Amplitude = fitParams(1);
    fittedSpotData(ii).Intensity = fitParams(1) * fitParams(4) * sqrt(2 * pi);
    fittedSpotData(ii).Rsq = Rsq;

end

end