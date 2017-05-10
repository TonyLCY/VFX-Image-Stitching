%function main(folder)
    folder = '..\input_image\parrington';
    % Read images
    disp('Loading images...');
    [images, N] = reader(folder);

    % Detect features
    disp('Detecting features...');
    N = 2;
    for i = 1:N
        features = HarrisDetector(images{i});
        disp(size(features));
        featureDrawer(images{i}, features, int2str(i));
        imgsFeat{i} = features;
    end

    % Match features
    focalLength = 705;
    matches = {};
    disp('Matching features...');
    for i = 1:N-1
        n = size(imgsFeat{i},2);
        feats = zeros(n,128);
        for j=1:n
            feats(j,:) = imgsFeat{i}{j}.descript;
        end
        searcher = KDTreeSearcher(feats);
        n2 = size(imgsFeat{i+1},2);
        matches{i} = zeros(n2,4);
        [H,W,C] = size(images{i});
        for j=1:n2
            desc2 = imgsFeat{i+1}{j}.descript;
            feat1 = imgsFeat{i}{knnsearch(searcher,desc2)};
            feat2 = imgsFeat{i+1}{j};
            matches{i}(j,1:2) = [feat2.x feat2.y];%getCylindricalCoordinates(feat2.x,feat2.y,H,W,focalLength);
            matches{i}(j,3:4) = [feat1.x feat1.y];%getCylindricalCoordinates(feat1.x,feat1.y,H,W,focalLength);
        end
        %matchDrawer(cylindricalProjection(images{i+1},focalLength),cylindricalProjection(images{i},focalLength),matches{i},int2str(i));
        matchDrawer(images{i+1},images{i},matches{i},int2str(i));
    end

    % Match images
    disp('Matching images...');
    trans = zeros(N-1,2);
    for i = 1:N-1
        % RANSAC
        mx = 0;
        off = [0 0];
        for j = 1:20
            n = size(matches{i},1);
            id = randsample(n,2);
            vec = (matches{i}(id(1),1,:)-matches{i}(id(1),2,:)) + (matches{i}(id(2),1,:)-matches{i}(id(2),2,:)) / 2;
            inlier = 0;
            for k = 1:n
                if norm(squeeze(matches{i}(k,2,:) + vec - matches{i}(k,1,:))) <= 100
                    inlier = inlier + 1;
                end
            end
            if inlier > mx
                mx = inlier;
                off = squeeze(vec);
            end
        end
        disp(off);
    end

    % Blend images
    disp('Blending images...');
    panoH = 100;
    panoW = 100;
    for i = i:N

    end

    % Write results
%end