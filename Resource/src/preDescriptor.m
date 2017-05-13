function [magnitude, angle] = preDescriptor(img)
    % Turn image to grey scale
    img = rgb2gray(img);

    % Convert img to double (to make gradient works)
    img = double(img);
    
    % Get Gaussian filter
    filter = fspecial('gaussian', [5 5], 1.5);

    % Smooth image
    img = filter2(filter, img);
    % Exclude the edges of the image
    Dx = img(2:(end - 1), 3:(end)) - img(2:(end - 1), 1:(end - 2));
    Dy = img(3:(end), 2:(end - 1)) - img(1:(end - 2), 2:(end - 1));

    magnitude = zeros(size(img));
    magnitude(2:(end - 1), 2:(end - 1)) = sqrt(Dx .^ 2 + Dy .^ 2);
    
    angle = zeros(size(img));
    angle(2:(end - 1), 2:(end - 1)) = atan2(Dy, Dx);
    % Turn all angles to positive
    angle(angle < 0) = angle(angle < 0) + 2 * pi;
end
