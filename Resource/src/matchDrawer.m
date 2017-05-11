function matchDrawer(img2, img1, match, name)
    % Write image with features
    [H,W,C] = size(img2);
    image = uint8(zeros(H,2*W,C));
    image(1:H,1:W,:) = img2;
    image(1:H,W+1:2*W,:) = img1;
    n = size(match, 1);
    pos = zeros(n, 4);
    for i = 3000:3500
    %for i = 1:size(match)
        pos(i,1) = match(i,2);
        pos(i,2) = match(i,1);
        pos(i,3) = match(i,4)+W;
        pos(i,4) = match(i,3);
    end
    image = insertShape(image,'Line',pos,'LineWidth',1);
    imwrite(image, ['../result/match_', name, '.jpg']);
end
