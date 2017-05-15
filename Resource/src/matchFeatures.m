function pairs = matchFeatures(feats1, feats2)
    n = size(feats1,2);
    descs = zeros(n,128);
    for j = 1:n
        descs(j,:) = feats1{j}.descript;
    end
    searcher = KDTreeSearcher(descs);
    n2 = size(feats2,2);
    pairs = zeros(n2,2);
    cnt = 0;
    for j = 1:n2
        desc2 = feats2{j}.descript;
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

        %feat1 = feats1{knnsearch(searcher,desc2)};
        cnt = cnt + 1;
        pairs(cnt,:) = [id(1),j];
    end
    pairs = pairs(1:cnt,:);
    disp('Found pairs:');
    disp(cnt);
end