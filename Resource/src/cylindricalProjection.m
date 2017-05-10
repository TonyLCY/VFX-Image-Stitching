function newImg = cylindricalProjection(oldImg, fLen)
    [H,W,C] = size(oldImg);
    newImg = uint8(zeros(H,W,C));
    for r = 1:H
        for c = 1:W
            x = r - (1+H)/2;
            y = c - (1+W)/2;
            y = fLen * tan(y/fLen);
            x = x * sqrt(y^2 + fLen^2) / fLen;
            x = x + (1+H)/2;
            y = y + (1+W)/2;
            if x<1 || x>H || y<1 || y>W
                continue
            end
            newImg(r,c,:) = oldImg(int16(x),int16(y),:);
        end
    end
end
