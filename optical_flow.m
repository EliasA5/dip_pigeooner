close all;
clc;

%global accumelated_features;
cam = webcam('USB Video Device');
cam.Resolution = '640x360';
cam.ExposureMode = 'auto';
cam.WhiteBalanceMode = 'auto';
fig = figure; sgtitle('click on figure and press q to stop');
load('extracted_features.mat', 'accumelated_features');

blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 5000);

opticFlow = opticalFlowFarneback;
threshhold = 3.5;
rgb_frame = snapshot(cam);
frame = rgb2gray(rgb_frame);
flow = estimateFlow(opticFlow,frame);

isOverlapping = @(box1,box2) (box1(1)+box1(3) >= box2(1) && box2(1)+box2(3) >= box1(1)...
                            && box1(2)+box1(4) >= box2(2) && box2(2)+box2(4) >= box1(2));

detected_bboxes = [];
expected_bboxes = [];
frames_count = [];
finish = false;
while(~finish)
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
    starty = tmp_bbox(2);endy = min(tmp_bbox(2)+tmp_bbox(4), height(frame));
    startx = tmp_bbox(1); endx = min(tmp_bbox(1)+tmp_bbox(3), length(frame));
    pigeon = isPigeon(rgb_frame(starty:endy,startx:endx, :), frame(starty:endy,startx:endx), accumelated_features);
    %pigeon = true;
    if(tmp_bbox(3)*tmp_bbox(4)*3 > numel(frame) || ~pigeon), continue; end
    if(isempty(expected_bboxes)), expected_bboxes = [tmp_bbox]; frames_count = [0]; continue; end
    to_del = bboxOverlapRatio(tmp_bbox, expected_bboxes, 'min') > 0.4;
    expected_bboxes(to_del, :) = [];
    frames_count(to_del) = [];
    expected_bboxes = [expected_bboxes; tmp_bbox];
    frames_count = [frames_count; 0];
end

to_del = zeros(height(expected_bboxes),1, 'logical');
for index=1:height(expected_bboxes)
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
        to_del(index) = 1;
    elseif(dx == 0 && dy == 0)
        frames_count(index) = frames_count(index) + 1;
        if(frames_count > 10)%TODO check if pigeon and remove accordingly
            to_del(index) = 1;
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
if(get(gcf,'CurrentCharacter') == 'q'), finish=true; end

end
clear cam;
close all;