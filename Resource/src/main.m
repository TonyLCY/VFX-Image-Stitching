function main(folder)

    % Read images
    disp('Loading images...');
    [images, N] = reader(folder);

    % Detect features
    disp('Detecting features...');
    %N = 1;
    for i = 1:N
        features = HarrisDetector(images{i});
        disp(size(features));
        featureDrawer(images{i}, features, int2str(i));
        imgsFeat{i} = features;
    end

    % Match features
    disp('Matching features...');

    % Match images
    disp('Matching images...');

    % Blend images
    disp('Blending images...');

    % Write results
end
