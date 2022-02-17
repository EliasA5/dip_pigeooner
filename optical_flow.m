close all;
clc;

cam = webcam('Microsoft');
cam.Resolution = string(cam.AvailableResolutions(2));
cam.ExposureMode = 'manual';
cam.WhiteBalanceMode = 'manual';
figure;
% ax = subplot(2, 2, 1); 
% frame = snapshot(cam); 
% im = image(ax,zeros(size(frame),'uint8')); 
% axis(ax,'image');
% preview(cam,im)


blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 5000);

opticFlow = opticalFlowFarneback;
threshhold = 3.5;
while(1)
pause(0.04);%get frame every 0.1 second
rgb_frame = snapshot(cam);

frame = rgb2gray(rgb_frame); 
%frame = imgaussfilt(frame,'FilterSize',21);

flow = estimateFlow(opticFlow,frame);
% flow.Magnitude(flow.Magnitude < threshhold) = 0;
% flow.Vx(flow.Magnitude < threshhold) = 0;
% flow.Vy(flow.Magnitude < threshhold) = 0;
% flow.Orientation(flow.Magnitude < threshhold) = 0;

subplot(2, 2, 3);
imshow(frame)
hold on;plot(flow,'DecimationFactor',[15 15],'ScaleFactor',2);
hold off;title('Optical Flow Vectors');
subplot(2,2,4);
imshow(flow.Magnitude);
colorbar;
subplot(2,2,2);
mask = medfilt2((flow.Magnitude > threshhold), [5 5]);
mask = imfill(mask, 'holes');
imshow(mask);

bbox = step(blobAnalysis, mask);
result = insertShape(rgb_frame, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 3);
subplot(2, 2, 1); imshow(result);





% result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 3);
% subplot(2, 2, 4); imshow(result); title('Detected Movment');
% alpha = 0.5;
% base_frame = (1-alpha).*base_frame + alpha.*frame;
% subplot(2, 2, 2);imshow(base_frame);
% title('Current Foreground');
end