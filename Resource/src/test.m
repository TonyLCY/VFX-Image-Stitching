a = 1;
disp(ceil(a / 2));
%{
ang = pi * 1.5;
dir = [-0.5, 0.5];
disp(sin(ang));
disp(round(dir));
rot = [cos(ang) -sin(ang); sin(ang) cos(ang)];
res = dir * rot;
disp(res);
disp(round(res));
%}
