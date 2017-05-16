function [img, off, lr] = cylindricalProjection(oldImg, offset, fLen)
    off = ceil(offset);
    [H,W,C] = size(oldImg);
    img = zeros(H,W,C);
    lr = [W, 1];
    for i = 1:H
        for j = 1:W
            y = i + (off(2)-offset(2)) - (1+H)/2;
            x = j + (off(1)-offset(1)) - (1+W)/2;
            x = fLen * tan(x/fLen);
            y = y * sqrt(x^2 + fLen^2) / fLen;
            y = y + (1+H)/2;
            x = x + (1+W)/2;
            if y>=1 && y<=H && x>=1 && x<=W
                img(i,j,:) = oldImg(int16(y),int16(x),:);
                lr(1) = min(lr(1),x);
                lr(2) = max(lr(2),x);
            end
        end
    end
    off = int32(off);
    lr = int32(lr);
end
