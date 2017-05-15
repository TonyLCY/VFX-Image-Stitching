function pano = blendImages(images, N, fLen, trans)
    %trans(1,:) = [-245,-4];
    [H, W, C] = size(images{1});
    minXY = [1, 1];
    maxXY = [1, 1];
    accXY = [1, 1];
    for i = 1:N-1
        accXY = accXY + round(trans(i,:));
        minXY = min(minXY, accXY);
        maxXY = max(maxXY, accXY);
    end
    panoWH = maxXY - minXY + [W,H];
    pano = zeros(panoWH(2),panoWH(1),3);
    tmp = getCylindricalCoordinates(0.5,0,H,W,mean(fLen));
    LL = ceil(tmp(1));
    tmp = getCylindricalCoordinates(W+0.5,0,H,W,mean(fLen));
    RR = floor(tmp(1));
    accXY = [1, 1];
    for i = 1:N
        img = double(cylindricalProjection(images{i},fLen(i)));
        wei = ones(1, W);
        if i > 1
            l = LL;
            r = RR;
            if trans(i-1,1) < 0
                l = l-int32(trans(i-1,1));
                wei(l:r) = linspace(1,0,r-l+1);
            else
                r = r-int32(trans(i-1,1));
                wei(l:r) = linspace(0,1,r-l+1);
            end
        end
        if i < N
            l = LL;
            r = RR;
            if trans(i,1) > 0
                l = l+int32(trans(i,1));
                wei(l:r) = linspace(1,0,r-l+1);
            else
                r = r+int32(trans(i,1));
                wei(l:r) = linspace(0,1,r-l+1);
            end
        end
        img = img .* wei(ones(1, H), :);
        ul = int32(accXY - minXY + [1, 1]);
        dr = ul + int32([W-1, H-1]);
        %disp([ul,dr]);
        pano(ul(2):dr(2),ul(1):dr(1),:) = pano(ul(2):dr(2),ul(1):dr(1),:) + img;
        accXY = accXY + round(trans(i,:));
    end
    pano = uint8(pano);
end
