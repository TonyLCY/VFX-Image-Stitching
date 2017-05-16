function pos = getCylindricalCoordinates(x, y, H, W, f)
    x = x - (1+W)/2;
    y = y - (1+H)/2;
    xx = f * atan(x / f);
    yy = y * f / sqrt(x^2 + f^2);
    xx = xx + (1+W)/2;
    yy = yy + (1+H)/2;
    pos = [xx, yy];
end
