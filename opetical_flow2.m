close all;
clear vars;
clc;

cam = webcam(1);
cam.Resolution = string(cam.AvailableResolutions(6));
cam.ExposureMode = 'auto';
cam.WhiteBalanceMode = 'auto';
figure;
% ax = subplot(2, 2, 1); 
% frame = snapshot(cam); 
% im = image(ax,zeros(size(frame),'uint8')); 
% axis(ax,'image');
% preview(cam,im)

blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 3000);

opticFlow = opticalFlowFarneback;
threshhold = 3.5;

Predicted_bboxes = [];

while(1)
pause(0.04);%get frame every 0.1 second
rgb_frame = snapshot(cam);
subplot(2, 2, 1);imshow(rgb_frame);

frame = rgb2gray(rgb_frame);

%check if object inside bbox is pigeon, remove if not

flow = estimateFlow(opticFlow,frame);
subplot(2,2,2);
imshow(frame)
hold on;plot(flow,'DecimationFactor',[5 5],'ScaleFactor',1);
hold off;title('Optical Flow Vectors');
mask = medfilt2((flow.Magnitude > threshhold), [5 5]);
mask = imfill(mask, 'holes');
subplot(2,2,3);imshow(mask);



bbox = step(blobAnalysis, mask);

bboxes = [bbox ; Predicted_bboxes];

result = insertShape(frame, 'Rectangle', bboxes, 'Color', 'green', 'LineWidth', 3);
subplot(2,2,4); imshow(result);

bboxes = remove_overlap(bboxes);

Predicted_bboxes = bboxes;
result = insertShape(frame, 'Rectangle', Predicted_bboxes, 'Color', 'green', 'LineWidth', 3);
subplot(2,2,4); imshow(result);

for i = 1:height(Predicted_bboxes)
    x = Predicted_bboxes(i,1);
    y = Predicted_bboxes(i,2);
    end_x = min(x+Predicted_bboxes(i,3),length(frame));
    end_y = min(y+Predicted_bboxes(i,4),height(frame));
    dx = int32(mean(flow.Vx(y:end_y,x:end_x),'all'));
    dy = int32(mean(flow.Vy(y:end_y,x:end_x),'all'));
    new_x = max(Predicted_bboxes(i,1) + dx, 1);
    new_x = min(new_x, length(frame));
    new_y = max(Predicted_bboxes(i,2) + dy, 1);
    new_y = min(new_y, height(frame));
    Predicted_bboxes(i,1) = new_x;
    Predicted_bboxes(i,2) = new_y;
end


end


function [bboxes] = remove_overlap(bbox)
if height(bbox) < 2
    bboxes = bbox;
else
overlap_area = double(rectint(bbox,bbox));
N=size(overlap_area,1);
I = eye(N);
bbox_area = overlap_area(I==1);
overlap_area=reshape(overlap_area(I~=1),N-1,N).';
overlap_ratio = overlap_area./bbox_area;

overlap_bool = overlap_ratio > 0.4;

idx = zeros(1,N);
for i =1:N
    bbox_overlap = overlap_bool(i,:);
    if(any(bbox_overlap))
        idx(i) = 1;
        overlap_bool(:,i) = 0;
    end
end

bboxes = bbox(~idx,:);
end

end