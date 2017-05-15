function matchDrawer(imgs, pairs, name)
    % Write image with features
    [H,W,C] = size(imgs{1});
    image = uint8(zeros(H,2*W,C));
    image(1:H,1:W,:) = imgs{1};
    image(1:H,W+1:2*W,:) = imgs{2};
    n = size(pairs, 1);
    pos = zeros(n, 4);
    for i = 1:n
        pos(i,1) = pairs(i,1);
        pos(i,2) = pairs(i,2);
        pos(i,3) = pairs(i,3)+W;
        pos(i,4) = pairs(i,4);
    end
    image = insertShape(image,'Line',pos,'LineWidth',1);
    imwrite(image, ['../result/match_', name, '.jpg']);
end
