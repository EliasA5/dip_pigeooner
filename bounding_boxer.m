close all;
clc;

figure; hold on;
files = dir(fullfile(pwd, "*.jpg"));
bounding_boxes = zeros(length(files), 4);

for i=1:length(files)
    img = imread(fullfile(files(i).folder , files(i).name));
    imshow(img);
    [x, y] = ginput(2); %clockwise starting from upper left corner
    bounding_boxes(i,:) = [x(1), y(1), abs(x(2)-x(1)), abs(y(2)-y(1))];%[x, y, width, length]
    
end