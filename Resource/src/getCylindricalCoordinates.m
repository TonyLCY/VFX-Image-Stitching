function pos = getCylindricalCoordinates(x, y, H, W, R, f)
    y = y - (1+H)/2;
    x = x - (1+W)/2;
    y = y * R / sqrt(x^2 + f^2);
    x = R * atan(x / f);
    y = y + (1+H)/2;
    x = x + (1+W)/2;
    pos = [x, y];
end
