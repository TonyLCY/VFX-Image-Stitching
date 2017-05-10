function pos = getCylindricalCoordinates(x, y, H, W, f)
    x = x - (1+H)/2;
    y = y - (1+W)/2;
    xx = f * x / sqrt(y^2 + f^2);
    yy = f * atan(y / f);
    xx = xx + (1+H)/2;
    yy = yy + (1+W)/2;
    pos = [xx, yy];
end
