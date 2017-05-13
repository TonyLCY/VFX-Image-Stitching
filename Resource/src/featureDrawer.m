function featureDrawer(image, features, name)
    % Write image with features
    for j = 1:size(features, 2)
        x = features{j}.x;
        y = features{j}.y;
        image(y, x, 1) = 0;
        image(y, x, 2) = 0;
        image(y, x, 3) = 255;
        %{
        image(x, y, 1) = 0;
        image(x, y, 2) = 0;
        image(x, y, 3) = 255;
        %}
    end
    imwrite(image, ['../result/features_', name, '.png']);
end
