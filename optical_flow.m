close all;
clc;

cam = webcam('USB Video Device');
cam.Resolution = string(cam.AvailableResolutions(2));
cam.ExposureMode = 'auto';
cam.WhiteBalanceMode = 'auto';
fig = figure;
% ax = subplot(2, 2, 1); 
% frame = snapshot(cam); 
% im = image(ax,zeros(size(frame),'uint8')); 
% axis(ax,'image');
% preview(cam,im)


blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 5000);

opticFlow = opticalFlowFarneback;
threshhold = 3.5;
rgb_frame = snapshot(cam);
frame = rgb2gray(rgb_frame);
flow = estimateFlow(opticFlow,frame);

detected_bboxes = [];
expected_bboxes = [];
frames_count = [];
while(1)
pause(0.04);%get frame every 0.1 second
rgb_frame = snapshot(cam);

frame = rgb2gray(rgb_frame);

flow = estimateFlow(opticFlow,frame);

mask = imfill(medfilt2((flow.Magnitude > threshhold), [5 5]), 'holes');

bbox = step(blobAnalysis, mask);
%check if object inside bbox is pigeon, remove entry if not

for i=1:height(bbox)
    %check every box 
    tmp_bbox = bbox(i,:);
    if(tmp_bbox(3)*tmp_bbox(4)*3 > numel(frame))
        continue;
    end
    if(numel(expected_bboxes) == 0)
        expected_bboxes = [tmp_bbox];
        frames_count = [0];
        break;
    end
    distances = (tmp_bbox(1) - expected_bboxes(:,1)).^2 + (tmp_bbox(2) - expected_bboxes(:,2)).^2;
    %[val, index] = min(distances, [], 'all');
    to_del = distances<600; %TODO check this threshhold
    if(numel(to_del) > 0)
        expected_bboxes(to_del, :) = [];
        frames_count(to_del) = [];
        expected_bboxes = [expected_bboxes; tmp_bbox];
        frames_count = [frames_count; 0];
    else
        expected_bboxes = [expected_bboxes; tmp_bbox];
        frames_count= [frames_count; 0];
    end
end

to_del = [];
for index=1:height(expected_bboxes)
    if(index > height(expected_bboxes))
        a = 0;
    end
    startx = expected_bboxes(index, 1);
    endx = min(expected_bboxes(index, 1)+expected_bboxes(index, 3), length(frame));
    starty = expected_bboxes(index, 2);
    endy = min(expected_bboxes(index, 2)+expected_bboxes(index, 4), height(frame));
    dx = int32(mean(flow.Vx(starty: endy, startx:endx), 'all'));
    dy = int32(mean(flow.Vy(starty: endy, startx:endx), 'all'));
    expected_bboxes(index, 1) = expected_bboxes(index, 1) + dx;
    expected_bboxes(index, 2) = expected_bboxes(index, 2) + dy;
    if(expected_bboxes(index, 1) < 1 ||  expected_bboxes(index, 1) > length(frame) ||...
            expected_bboxes(index, 2) < 1 || expected_bboxes(index, 2) > height(frame))
        to_del = [to_del; index];
    elseif(dx == 0 && dy == 0)
        frames_count(index) = frames_count(index) + 1;
        if(frames_count > 10)%TODO check if pigeon and remove accordingly
            to_del = [to_del; index];
        end
    end
end
expected_bboxes(to_del, :) = [];
frames_count(to_del) = [];
result = insertShape(frame, 'Rectangle', expected_bboxes, 'Color', 'green', 'LineWidth', 3);
subplot(1, 2, 1); imshow(result);
hold on;plot(flow,'DecimationFactor',[15 15],'ScaleFactor',2);
hold off;title('Optical Flow Vectors');
subplot(1, 2, 2);imshow(mask);


% result = insertShape(frame, 'Rectangle', bbox, 'Color', 'green', 'LineWidth', 3);
% subplot(2, 2, 4); imshow(result); title('Detected Movment');
% alpha = 0.5;
% base_frame = (1-alpha).*base_frame + alpha.*frame;
% subplot(2, 2, 2);imshow(base_frame);
% title('Current Foreground');
end