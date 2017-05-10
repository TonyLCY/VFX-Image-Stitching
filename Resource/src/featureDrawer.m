function featureDrawer(image, features, name)
    % Write image with features
    for j = 1:size(features, 2)
        x = features{j}.x;
        y = features{j}.y;
        image(x, y, 1) = 255;
        image(x, y, 2) = 0;
        image(x, y, 3) = 0;
    end
    imwrite(image, ['../result/features_', name, '.jpg']);
end
