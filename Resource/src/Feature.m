classdef Feature
    properties
        x
        y
        descript
        descripts
        orient
        orients
    end
    methods
        function feature = Feature(x, y, magnitude, angle, image)
            feature.x = x;
            feature.y = y;
            [row, col] = size(magnitude);
            
            % Define window for feature point
            halfwid = 4;
            wid = 2 * halfwid + 1;
            
            % Exclude out of bound patch
            if (y - halfwid) < 1 || (x - halfwid) < 1 || (y + halfwid) > row || (x + halfwid) > col
                feature.x = NaN;
                return;
            end

            %mag = zeros(wid, wid);
            mag = magnitude((y - halfwid):(y + halfwid), (x - halfwid):(x + halfwid));
            %ang = zeros(wid, wid);
            ang = angle((y - halfwid):(y + halfwid), (x - halfwid):(x + halfwid));
            

            % Computing magnitude and angle for every window would make the efficiency depending on the number of features.
            % Since that could be a drawback, we choose to do that prior to Feature creation in the end.
            %{
            x_l = max(2, x - halfwid);
            x_h = min(col - 1, x + halfwid);
            x_dif = x_h - x_l;

            y_l = max(2, y - halfwid);
            y_h = min(row - 1, y + halfwid);
            y_dif = y_h - y_l;

            magnitude = zeros(y_dif, x_dif);
            theta = zeros(y_dif, x_dif);

            % Compute magnitude and theta
            for yt = 1:y_dif
                for xt = 1:x_dif
                    magnitude(yt, xt) = sqrt((img(yt + y_l - 1, xt + x_l) - img(yt + y_l - 1, xt + x_l - 2)) ^ 2
                                    + (img(yt + y_l, xt + x_l - 1) - img(yt + y_l - 2, xt + x_l - 1)) ^ 2);
                    theta(yt, xt) = atan2((img(yt + y_l, xt + x_l - 1) - img(yt + y_l - 2, xt + x_l - 1)) 
                                    / (img(yt + y_l - 1, xt + x_l) - img(yt + y_l - 1, xt + x_l - 2))); 
                end
            end
            %}

            % Get Gaussian kernel
            sigma = 1.5;
            kernel = fspecial('gaussian', [wid wid], sigma);
            weighted_mag = kernel .* mag;

            % Construct weighted orientation histogram
            hist_step = pi / 18;
            bucket = zeros(36);
            for y_coor = 1:wid
                for x_coor = 1:wid
                    region = floor(ang(y_coor, x_coor) / hist_step) + 1;
                    border_diff = mod(ang(y_coor, x_coor), hist_step) / hist_step;
                    bucket(region) = bucket(region) + weighted_mag(y_coor, x_coor) * (1 - border_diff);
                    if region < 36
                        neighbor = region + 1;
                    else
                        neighbor = 1;
                    end
                    bucket(neighbor) = bucket(neighbor) + weighted_mag(y_coor, x_coor) * border_diff;
                end
            end

            % Find peak value and assign orientation
            [peak_value peak_index] = max(bucket);
            % Find potential multiple orientation
            feature.orients = find(bucket > (0.8 * peak_value));
            feature.orients = double(feature.orients) .* hist_step;

            wid = 16;
            coor_dir_trans = wid / 2 + 0.5;
            sigma = wid / 2;
            kernel = fspecial('gaussian', [wid wid], sigma);
            for i = 1:size(feature.orients)
                % Get the surrounding grid of feature after rotated to orientation
                % Define rotation matrix
                rot = [cos(feature.orients(i)) -sin(feature.orients(i)); sin(feature.orients(i)) cos(feature.orients(i))];

                % Define the magnitude and angle for the grid
                %rot_mag = zeros(wid, wid);
                %rot_ang = zeros(wid, wid);

                % Get rotated coordinate
                [Xd, Yd] = meshgrid(-coor_dir_trans:coor_dir_trans, -coor_dir_trans:coor_dir_trans);
                Xl = reshape(Xd, [], 1);
                Yl = reshape(Yd, [], 1);
                P = [Xl Yl];
                Pr = P * rot;
                Xl = Pr(:, 1);
                Xd = reshape(Xl, wid + 2, wid + 2);
                Yl = Pr(:, 2);
                Yd = reshape(Yl, wid + 2, wid + 2);

                Xd = Xd + feature.x;
                Yd = Yd + feature.y;

                % Interpolate gradient
                grid = interp2(image, Xd, Yd);
                grid(find(isnan(grid))) = 0;

                gDx = 0.5 * (grid(2:(end - 1), 3:(end)) - grid(2:(end - 1), 1:(end - 2)));
                gDy = 0.5 * (grid(3:(end), 2:(end - 1)) - grid(1:(end - 2), 2:(end - 1)));
                rot_mag = sqrt(gDx .^ 2 + gDy .^2);
                rot_ang = atan2(gDy, gDx);
                rot_ang(rot_ang < 0) = rot_ang(rot_ang < 0) + 2 * pi;
                rot_ang = rot_ang - feature.orients(i);
                rot_ang(rot_ang < 0) = rot_ang(rot_ang < 0) + 2 * pi;
                weighted_rot_mag = kernel .* rot_mag;
                %{
                for y_coor = 1:wid
                    for x_coor = 1:wid
                        x_dir = x_coor - coor_dir_trans;
                        y_dir = y_coor - coor_dir_trans;
                        rot_dir = round([y_dir, x_dir] * rot);
                        rot_y_coor = feature.y + rot_dir(1);
                        rot_x_coor = feature.x + rot_dir(2);

                        if rot_y_coor < 1 || rot_x_coor < 1 || rot_y_coor > row || rot_x_coor > col
                            rot_mag(y_coor, x_coor) = 0;
                            rot_ang(y_coor, x_coor) = 0;
                        else
                            rot_mag(y_coor, x_coor) = magnitude(rot_y_coor, rot_x_coor);
                            rot_ang(y_coor, x_coor) = angle(rot_y_coor, rot_x_coor) - feature.orients(i);
                        end
                        
                    end
                end
                rot_ang(rot_ang < 0) = rot_ang(rot_ang < 0) + 2 * pi;
                weighted_rot_mag = kernel .* rot_mag;
                %}

                % Extract Feature description
                desc = zeros(1, 128);
                
                win_size = wid / 4;
                hist_step = pi / 4;
                for y_coor = 1:wid
                    for x_coor = 1:wid
                        win = ceil(x_coor / win_size) + 4 * (ceil(y_coor / win_size) - 1);
                        reg = floor(rot_ang(y_coor, x_coor) / hist_step) + 1;
                        border_diff = mod(rot_ang(y_coor, x_coor), hist_step) / hist_step;
                        slot = 8 * (win - 1) + reg;
                        desc(slot) = desc(slot) + weighted_rot_mag(y_coor, x_coor) * (1 - border_diff);
                        if reg < 8
                            slot = slot + 1;
                        else
                            slot = slot - 7;
                        end
                        desc(slot) = desc(slot) + weighted_rot_mag(y_coor, x_coor) * border_diff;
                    end
                end
                

                if norm(desc) == 0
                    feature.descripts{i} = desc;
                    continue;
                end

                % Normalized description
                desc = desc / norm(desc);
                % Threshold largest value to 0.2 to reduce influence of large gradient magnitudes
                desc(desc > 0.2) = 0.2;
                desc = desc / norm(desc);

                feature.descripts{i} = desc;
            end
        end
    end
end
