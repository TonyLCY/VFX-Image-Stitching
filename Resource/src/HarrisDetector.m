function features = HarrisDetector(image)
    k = 0.04;
    threshold = 4000;
    sigma = 3;

    % Turn image to grey scale
    img = rgb2gray(image);

    % Convert img to double
    img = double(img);
    
    % Get Gaussian filter
    filter = fspecial('gaussian', [5 5], sigma);

    % Smooth image
    %img = filter2(filter, img);

    % Compute x, y derivatives
    [Ix, Iy] = gradient(img);

    % Compute products of derivatives
    Ix2 = Ix .^ 2;
    Iy2 = Iy .^ 2;
    Ixy = Ix .* Iy;

    % Compute sums of the products of derivatives
    Sx2 = filter2(filter, Ix2);
    Sy2 = filter2(filter, Iy2);
    Sxy = filter2(filter, Ixy);

    % Compute R = det(M) - k(trace(M)^2)
    R = (Sx2 .* Sy2 - Sxy .^ 2) - k * (Sx2 + Sy2) .^ 2;

    % Threshold on value R and compute nonmax suppression
    result = R > threshold;
    result = result & (R > imdilate(R, [1 1 1; 1 0 1; 1 1 1]));

    % Calculate magnitude and angle prior to Feature creating
    [mag, ang, img] = preDescriptor(image);

    % Create Feature objects
    [resultY, resultX] = find(result);
    features = {};
    %radius = 8;
    %r2 = radius ^ 2;
    for i = 1:size(resultY)
        % Ignore features with another feature within distance radius
        %{
        flag = 0;
        for j = 1:size(features, 2)
            if (resultY(i) - features{j}.y) ^ 2 + (resultX(i) - features{j}.x) ^ 2 < r2
                flag = 1;
                break;
            end
        end
        if flag == 1
            continue;
        end
        %}

        feature = Feature(resultY(i), resultX(i), mag, ang, img);
        
        % Grid surround feature out of bound
        if isnan(feature.x)
            continue;
        end
        
        % Split multiple orientations to individual features
        split_features = {};
        for j = 1:size(feature.orients)
            split_features{j}.x = feature.x;
            split_features{j}.y = feature.y;
            split_features{j}.orient = feature.orients(j);
            split_features{j}.descript = feature.descripts{j};
        end
        features = [features, split_features];
    end
end
