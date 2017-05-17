function matchDrawer(imgs, feats, idPairs, name)
    % Write image with features
    [H,W,C] = size(imgs{1});
    image = uint8(zeros(H,2*W,C));
    image(1:H,1:W,:) = imgs{1};
    image(1:H,W+1:2*W,:) = imgs{2};
    n = size(idPairs, 1);
    pos = zeros(n, 4);
    for i = 1:n
        pos(i,1) = feats{1}{idPairs(i,1)}.x;
        pos(i,2) = feats{1}{idPairs(i,1)}.y;
        pos(i,3) = feats{2}{idPairs(i,2)}.x+W;
        pos(i,4) = feats{2}{idPairs(i,2)}.y;
    end
    image = insertShape(image,'Line',pos,'LineWidth',2,'color',256*rand(n,3));
    imwrite(image, ['../result/match_', name, '.jpg']);
end
