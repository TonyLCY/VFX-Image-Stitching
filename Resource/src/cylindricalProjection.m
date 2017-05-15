function newImg = cylindricalProjection(oldImg, fLen)
    [H,W,C] = size(oldImg);
    newImg = uint8(zeros(H,W,C));
    for i = 1:H
        for j = 1:W
            r = i - (1+H)/2;
            c = j - (1+W)/2;
            c = fLen * tan(c/fLen);
            r = r * sqrt(c^2 + fLen^2) / fLen;
            r = r + (1+H)/2;
            c = c + (1+W)/2;
            if r>=1 && r<=H && c>=1 && c<=W
                newImg(i,j,:) = oldImg(int16(r),int16(c),:);
            end
        end
    end
end
