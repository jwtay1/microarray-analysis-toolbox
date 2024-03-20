function zz = gaussFunc(params, xdata)

amplitude = params(1);
xOffset = params(2);
yOffset = params(3);
width = params(4);
bias = params(5);

zz = amplitude .* ...
    exp( - ((xdata(:, :, 1) - xOffset).^2 ./(2 * width^2) + (xdata(:, :, 2) - yOffset).^2 ./(2 * width^2) ) ) + ...
    bias;

end