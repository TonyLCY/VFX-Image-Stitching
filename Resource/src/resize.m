function resize(folder1, folder2)
    file_format = fullfile(folder1, '*.JPG');
    files = dir(file_format);
    file_num = length(files);
    for i = 1:file_num
        filename = fullfile(folder1, files(i).name);
        img = imread(filename);
        [row, col, channel] = size(img);
        % scale down
        simg = imresize(img, [row / 4, col / 4]);
        result = simg;
        % rotate
        %rsimg = imrotate(simg, 270);
        %result = rsimg;
        % write
        imwrite(result, [folder2, '/image_', int2str(i),'.jpg']);
    end
end
