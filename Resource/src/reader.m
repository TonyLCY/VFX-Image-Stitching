function [images, file_num] = reader(folder)
    file_format = fullfile(folder, '*.jpg');
    files = dir(file_format);
    file_num = length(files);
    for i = 1:file_num
        filename = fullfile(folder, files(i).name);
        img = imread(filename);
        images{i} = img;
    end
end
