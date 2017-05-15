function posPairs = id2Pos(featPair, idPairs, H, W, fLen, index)
    n = size(idPairs,1);
    posPairs = zeros(n,4);
    for j = 1:n
        feat1 = featPair{1}{idPairs(j,1)};
        feat2 = featPair{2}{idPairs(j,2)};
        posPairs(j,1:2) = getCylindricalCoordinates(feat1.x,feat1.y,H,W,fLen(index));
        posPairs(j,3:4) = getCylindricalCoordinates(feat2.x,feat2.y,H,W,fLen(index+1));
    end
end
