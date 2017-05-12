function matchDrawer(img2, img1, match, name)
    % Write image with features
    [H,W,C] = size(img2);
    image = uint8(zeros(H,2*W,C));
    image(1:H,1:W,:) = img2;
    image(1:H,W+1:2*W,:) = img1;
    n = size(match, 2);
    pos = zeros(n, 4);
    disp(n);
    for i = 300:n
        pos(i,1) = match{i}(1);
        pos(i,2) = match{i}(2);
        pos(i,3) = match{i}(3)+W;
        pos(i,4) = match{i}(4);
    end
    image = insertShape(image,'Line',pos,'LineWidth',1);
    imwrite(image, ['../result/match_', name, '.jpg']);
end
