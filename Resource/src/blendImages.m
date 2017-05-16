function pano = blendImages(images, N, R, fLens, trans)
    [H, W, C] = size(images{1});
    minXY = [0, 0];
    maxXY = [0, 0];
    accXY = [0, 0];
    for i = 1:N-1
        accXY = accXY + trans(i,:);
        minXY = min(minXY, accXY);
        maxXY = max(maxXY, accXY);
    end
    panoWH = int32(ceil(maxXY - minXY + [W,H]));
    pano = zeros(panoWH(2),panoWH(1),3);
    
    accXY = -minXY;
    LR = [panoWH(2), 1];
    for i = 1:N
        [img, pos, lr] = cylindricalProjection(images{i},accXY,R,fLens(i));
        wei = zeros(1,W);
        if lr(1)<LR(2)-pos(1) && LR(2)-pos(1)<lr(2)
            tl = lr(1);
            tr = LR(2)-pos(1);
            wei(tl:tr) = linspace(0,1,tr-tl+1);
        elseif lr(1)<LR(1)-pos(1) && LR(1)-pos(1)<lr(2)
            tl = LR(1)-pos(1);
            tr = lr(2);
            wei(tl:tr) = linspace(1,0,tr-tl+1);
        end
        for r = 1:H
            for c = 1:W
                rr = pos(2)+r;
                cc = pos(1)+c;
                if ~any(pano(rr,cc,:))
                    pano(rr,cc,:) = img(r,c,:);
                elseif any(img(r,c,:))
                    pano(rr,cc,:) = pano(rr,cc,:)*(1-wei(c))+img(r,c,:)*wei(c);
                end
            end
        end
        LR(1) = min(LR(1),pos(1)+lr(1));
        LR(2) = max(LR(2),pos(1)+lr(2));
        accXY = accXY + trans(i,:);
    end
    pano = uint8(pano);
end
