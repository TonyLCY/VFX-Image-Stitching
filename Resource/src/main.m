%function main(folder)
    folder = '..\input_image\parrington';
    % Read images
    disp('Loading images...');
    [images, N] = reader(folder);
    
    % Detect features
    disp('Detecting features...');
    N = 2;
    [H, W, C] = size(images{1});
    %{
    for i = 1:N
        features = HarrisDetector(images{i});
        disp(size(features));
        featureDrawer(images{i}, features, int2str(i));
        imgsFeat{i} = features;
    end

    %{
    disp(imgsFeat{1}{3}.x);
    disp(imgsFeat{1}{3}.y);
    disp(imgsFeat{1}{3}.orient);
    disp(imgsFeat{1}{3}.descript);
    disp(imgsFeat{1}{32}.x);
    disp(imgsFeat{1}{32}.y);
    disp(imgsFeat{1}{32}.orient);
    disp(imgsFeat{1}{32}.descript);
    %}
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
        matches{i} = {};
        for j=1:n2
            desc2 = imgsFeat{i+1}{j}.descript;
            %{
            [IDX, D] = knnsearch(searcher, desc2, 'IncludeTies', true);
            disp(IDX);
            disp(D);
            disp('======');
            %}
            [id, dist] = knnsearch(searcher, desc2, 'k', 2);
            if dist(1) / dist(2) > 0.8
                continue;
            end
           
            %feat1 = imgsFeat{i}{knnsearch(searcher,desc2)};
            feat1 = imgsFeat{i}{id(1)};
            feat2 = imgsFeat{i+1}{j};
            % fix index problem
            tmp = zeros(1,4);
            tmp(1:2) = getCylindricalCoordinates(feat2.x,feat2.y,H,W,focalLength);
            tmp(3:4) = getCylindricalCoordinates(feat1.x,feat1.y,H,W,focalLength);
            matches{i} = [matches{i}, tmp];
        end
        matchDrawer(cylindricalProjection(images{i+1},focalLength),cylindricalProjection(images{i},focalLength),matches{i},int2str(i));
        %matchDrawer(images{i+1},images{i},matches{i},int2str(i));
    end

    % Match images
    disp('Matching images...');
    trans = zeros(N,2);
    for i = 1:N-1
        % RANSAC
        tmp_cnt = 0;
        tmp_vec = zeros(2);
        for j = 1:20
            n = size(matches{i},2);
            id = randsample(n,2);
            vec = (matches{i}{id(1)}(1:2)-matches{i}{id(1)}(3:4)) + (matches{i}{id(2)}(1:2)-matches{i}{id(2)}(3:4)) / 2;
            c = 0; % temp inlier
            for k = 1:n
                if norm(matches{i}{k}(1:2) - matches{i}{k}(3:4) - vec) <= 100
                    c = c + 1;
                end
            end
            if c > tmp_cnt
                tmp_cnt = c;
                tmp_trans = vec;
            end
        end
        disp([tmp_cnt,tmp_trans]);
        vecs = zeros(n,2);
        for k = 1:n
            if norm(matches{i}{k}(1:2) - matches{i}{k}(3:4) - tmp_trans) <= 100
                vecs(k,:) = matches{i}{k}(1:2) - matches{i}{k}(3:4);
            end
        end
        trans(i,:) = sum(vecs)/tmp_cnt;
        disp([cnt,trans]);
    end
    %}
    % Blend images
    disp('Blending images...');
    minXY = [1, 1];
    maxXY = [1, 1];
    accXY = [1, 1];
    % 1: 123 109
    % 2: 125 358
    trans = zeros(N,2);
    trans(1,:) = [4, 245];
    for i = 1:N-1
        accXY = accXY - round(trans(i,:));
        minXY = min(minXY, accXY);
        maxXY = max(maxXY, accXY);
    end
    maxXY = maxXY + [H-1, W-1];
    pano = zeros([maxXY-minXY+[1,1], 3]);
    accXY = [1, 1];
    tmp = getCylindricalCoordinates(0,0.5,H,W,focalLength);
    LL = ceil(tmp(2));
    tmp = getCylindricalCoordinates(0,W+0.5,H,W,focalLength);
    RR = floor(tmp(2));
    for i = 1:N
        img = double(cylindricalProjection(images{i},focalLength));
        wei = ones(1, W);
        l = LL;
        r = RR;
        if i > 1
            if trans(i-1,2) > 0
                l = l+int32(trans(i-1,2));
                wei(l:r) = linspace(1,0,r-l+1);
            else
                r = r+int32(trans(i-1,2));
                wei(l:r) = linspace(0,1,r-l+1);
            end
        end
        if i < N
            if trans(i,2) < 0
                l = l-int32(trans(i,2));
                wei(l:r) = linspace(1,0,r-l+1);
            else
                r = r-int32(trans(i,2));
                wei(l:r) = linspace(0,1,r-l+1);
            end
        end
        img = img .* wei(ones(1, H), :);
        ul = int32(accXY - minXY + [1, 1]);
        dr = ul + int32([H-1, W-1]);
        pano(ul(1):dr(1),ul(2):dr(2),:) = pano(ul(1):dr(1),ul(2):dr(2),:) + img;
        accXY = accXY - round(trans(i,:));
    end
    % Write results
    pano = uint8(pano);
    imwrite(pano,'pano.png');
%end
