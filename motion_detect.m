close all;
clc;

cam = webcam(1);
fig = figure;
ax = subplot(2, 2, 1); 
frame = snapshot(cam); 
im = image(ax,zeros(size(frame),'uint8')); 
axis(ax,'image');
preview(cam,im)

base_frame = double(rgb2gray(snapshot(cam)))/255; 
base_frame = imgaussfilt(base_frame,'FilterSize',21);
subplot(2, 2, 2);imshow(base_frame);
title('Current Foreground');

blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 1500);

prev_filteredForeground = 0;
frame_change = 0;

while(1)
pause(0.1);%get frame every 0.1 second
frame = double(rgb2gray(snapshot(cam)))/255; 
frame = imgaussfilt(frame,'FilterSize',21);

foreground = (abs(frame - base_frame)) > 0.1;
filteredForeground = medfilt2(foreground,[5 5]); 
filteredForeground = imfill(filteredForeground,'holes');


subplot(2, 2, 3);imshow(filteredForeground);title('Detected Movment');

bbox = step(blobAnalysis, filteredForeground);



result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green');
subplot(2, 2, 4); imshow(result); title('Detected Movment');

base_frame = ((9.*base_frame)+frame)/10;
subplot(2, 2, 2);imshow(base_frame);
title('Current Foreground');
end