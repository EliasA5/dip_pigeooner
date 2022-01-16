close all;
clear vars;
clc;

foregroundDetector = vision.ForegroundDetector('NumTrainingFrames', 10);

cam = webcam(1);
fig = figure;
ax = subplot(2, 2, 1); 
frame = rgb2gray(snapshot(cam)); 
im = image(ax,zeros(size(frame),'uint8')); 
axis(ax,'image');
preview(cam,im)

%get background
for i = 1:10
    frame = rgb2gray(snapshot(cam)); 
    foreground = step(foregroundDetector, frame);
end


subplot(2, 2, 2);imshow(frame);
title('Current Foreground');

blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 1500);

prev_filteredForeground = 0;
frame_change = 0;

while(1)
pause(0.1);%get frame every 0.1 second
frame = rgb2gray(snapshot(cam)); 
foreground = foregroundDetector(frame);
filteredForeground = medfilt2(foreground,[5 5]); 
filteredForeground = medfilt2(filteredForeground,[5 5]); 
filteredForeground = medfilt2(filteredForeground,[5 5]); 

filted_mask = frame;
filted_mask(~filteredForeground) = 0;
subplot(2, 2, 3);imshow(filted_mask);title('Detected Movment');
bbox = step(blobAnalysis, filteredForeground);

change = nnz(prev_filteredForeground)/nnz(filteredForeground + prev_filteredForeground);
if(change > 0.9)
    frame_change = frame_change + 1;
else
    frame_change = 0;
end
if(change > 0.9 && frame_change == 15)
    foregroundDetector = vision.ForegroundDetector('NumTrainingFrames', 10);
    for i = 1:10
        frame = rgb2gray(snapshot(cam)); 
        foreground = step(foregroundDetector, frame);
    end
    subplot(2, 2, 2);imshow(frame);
    title('Current Foreground');
end
prev_filteredForeground = filteredForeground;


result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
subplot(2, 2, 4); imshow(result); title('Detected Movment');
end