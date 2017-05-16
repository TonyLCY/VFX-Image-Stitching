function main(folder)
    %folder = '..\input_image\parrington';
    
    % Read images
    disp('Loading images...');
    [images, fLens, N] = reader(folder);
    [H, W, C] = size(images{1});
    
    % Detect features
    disp('Detecting features...');
    for i = 1:N
        features = HarrisDetector(images{i});
        %featureDrawer(images{i}, features, num2str(i, '%02d'));
        disp('Found features:');
        disp(size(features, 2));
        imgsFeat{i} = features;
    end

    % Match features
    matchIds = {};
    disp('Matching features...');
    for i = 1:N-1
        matchIds{i} = matchFeatures(imgsFeat{i},imgsFeat{i+1});
        matchDrawer({images{i},images{i+1}},{imgsFeat{i},imgsFeat{i+1}},matchIds{i},num2str(i, '%02d'));
    end

    % Match images
    disp('Matching images...');
    trans = zeros(N,2);
    for i = 1:N-1
        posPairs = id2Pos({imgsFeat{i},imgsFeat{i+1}},matchIds{i},H,W,fLens(i:i+1));
        trans(i,:) = calculateTranslation(posPairs);
    end
    
    % Blend images
    disp('Blending images...');
    pano = blendImages(images, N, fLens, trans);
    
    % Write results
    %imwrite(pano,[folder,'/pano.png']);
-   imwrite(pano, '../result/pano.png');
end
