close all;
clc;

figure; hold on;
files = dir(fullfile(pwd, "*.jpg"));
bounding_boxes = zeros(length(files), 4);
file_names = strings(length(files), 1);

for i=1:length(files)
    file_names(i) = fullfile(files(i).folder , files(i).name);
    img = imread(file_names(i));
    imshow(img);
    [x, y] = ginput(2); %clockwise starting from upper left corner
    bounding_boxes(i,:) = [x(1), y(1), abs(x(2)-x(1)), abs(y(2)-y(1))];%[x, y, width, length]
    
end

output = struct('files', file_names, 'bounding_boxes', bounding_boxes); 
save('bounding_boxes','output');
%load('bounding_boxes.mat', 'output')