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
        function feature = Feature(x, y, magnitude, angle)
            feature.x = x;
            feature.y = y;
            [row, col] = size(magnitude);
            
            % Define window for feature point
            halfwid = 8;
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
            bucket = zeros(36);
            for y = 1:wid
                for x = 1:wid
                    region = floor(ang(y, x) / (pi / 18)) + 1;
                    bucket(region) = bucket(region) + weighted_mag(y, x);
                end
            end

            % Find peak value and assign orientation
            [peak_value peak_index] = max(bucket);
            % Find potential multiple orientation
            feature.orients = find(bucket > (0.8 * peak_value));
            feature.orients = double(feature.orients) .* (pi / 18);

            wid = 16;
            coor_dir_trans = wid / 2 + 0.49;
            kernel = fspecial('gaussian', [wid wid], sigma);
            for i = 1:size(feature.orients)
                % Get the surrounding grid of feature after rotated to orientation
                % Define rotation matrix
                rot = [cos(feature.orients(i)) -sin(feature.orients(i)); sin(feature.orients(i)) cos(feature.orients(i))];

                % Define the magnitude and angle for the grid
                rot_mag = zeros(wid, wid);
                rot_ang = zeros(wid, wid);

                % Get rotated coordinate
                for y_coor = 1:wid
                    for x_coor = 1:wid
                        % Assume the coordinates to be within [-7.49:7.51, -7.49:7.51] distant from feature point
                        % Deviate from 0.5 to include the feature point itself while rounding
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
                            %rot_ang(y_coor, x_coor) = angle(rot_y_coor, rot_x_coor);
                            rot_ang(y_coor, x_coor) = angle(rot_y_coor, rot_x_coor) - feature.orients(i);
                            if rot_ang(y_coor, x_coor) < 0
                                rot_ang(y_coor, x_coor) = rot_ang(y_coor, x_coor) + 2 * pi;
                            end
                        end
                    end
                end
                weighted_rot_mag = kernel .* rot_mag;
                %weighted_rot_mag = rot_mag;
                %disp(weighted_rot_mag);
                %disp(rot_ang);
                %disp('====');

                % Extract Feature description
                desc = zeros(1, 128);
                win_size = wid / 4;
                for y_coor = 1:wid
                    for x_coor = 1:wid
                        win = ceil(x_coor / win_size) + 4 * (ceil(y_coor / win_size) - 1);
                        reg = floor(rot_ang(y_coor, x_coor) / (pi / 4)) + 1;
                        slot = 8 * (win - 1) + reg;
                        desc(slot) = desc(slot) + weighted_rot_mag(y_coor, x_coor);
                    end
                end

                % Normalized description
                desc = desc / norm(desc);
                % Threshold largest value to 0.2 to reduce influence of large gradient magnitudes
                desc(desc > 0.2) = 0.2;
                desc = desc / norm(desc);
                %disp(desc);

                feature.descripts{i} = desc;
            end
        end
    end
end
