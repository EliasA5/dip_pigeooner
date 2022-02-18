close all;
clc;

cam = webcam(1);
% cam.Resolution = string(cam.AvailableResolutions(2));
cam.ExposureMode = 'auto';
cam.WhiteBalanceMode = 'auto';
figure;
% ax = subplot(2, 2, 1); 
% frame = snapshot(cam); 
% im = image(ax,zeros(size(frame),'uint8')); 
% axis(ax,'image');
% preview(cam,im)


blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 2500);

opticFlow = opticalFlowFarneback;
threshhold = 3.5;

isOverlappingX = @(box1,box2) (box1(1)+box1(3) >= box2(1) && box2(1)+box2(3) >= box1(1));
isOverlappingY = @(box1,box2) (box1(2)+box1(4) >= box2(2) && box2(2)+box2(4) >= box1(2));
isOverlapping = @(box1,box2) (isOverlappingX(box1,box2) && isOverlappingY(box1,box2));
detected_bboxes = [];

while(1)
pause(0.04);%get frame every 0.1 second
rgb_frame = snapshot(cam);

frame = rgb2gray(rgb_frame);

%check if object inside bbox is pigeon, remove if not
for i=1:height(detected_bboxes)
    %check if pigeon in bbox else remove
    continue;
end


flow = estimateFlow(opticFlow,frame);
subplot(2, 2, 3);
imshow(frame)
hold on;plot(flow,'DecimationFactor',[15 15],'ScaleFactor',2);
hold off;title('Optical Flow Vectors');
subplot(2,2,4);imshow(flow.Magnitude);colorbar;
mask = medfilt2((flow.Magnitude > threshhold), [5 5]);
mask = imfill(mask, 'holes');
subplot(2,2,2);imshow(mask);

bbox = step(blobAnalysis, mask);

%check if object inside bbox is pigeon, remove if not

%check if bbox overlap
for i = 1:height(bbox)
    area_1 = zeros(size(frame),'logical');
    x = bbox(i,1);
    y = bbox(i,2);
    end_x = min(x+bbox(i,3),length(frame));
    end_y = min(y+bbox(i,4),height(frame));
    area_1(y:end_y,x:end_x) = 1;
    if(height(detected_bboxes) >= 1)
        for j = height(detected_bboxes):1
            if(~isOverlapping(bbox(i,:), detected_bboxes(j,:)))
                continue;
            end
            area_2 = zeros(size(frame),'logical');
            t_x = detected_bboxes(j,1);
            t_y = detected_bboxes(j,2);
            t_end_x = min(t_x+detected_bboxes(j,3),length(frame));
            t_end_y = min(t_y+detected_bboxes(j,4),height(frame));
            area_2(t_y:t_end_y,t_x:t_end_x)= 1;
            overlap_area = sum(area_2 & area_1,'all');
            overlap = overlap_area/sum(area_2 | area_1,'all');
            overlap_1 = overlap_area/sum(area_2,'all');
            overlap_2 = overlap_area/sum(area_1,'all');
            if(overlap> 0.6 || overlap_1 > 0.8 || overlap_2 > 0.8)
                detected_bboxes(j,:) = [];
                break;
            end
        end
    end
end

detected_bboxes = [detected_bboxes; bbox];

result = insertShape(rgb_frame, 'Rectangle', detected_bboxes, 'Color', 'green', 'LineWidth', 3);


subplot(2, 2, 1); imshow(result);



for i = 1:height(detected_bboxes)
    x = detected_bboxes(i,1);
    y = detected_bboxes(i,2);
    end_x = min(x+detected_bboxes(i,3),length(frame));
    end_y = min(y+detected_bboxes(i,4),height(frame));
    dx = int32(mean(flow.Vx(y:end_y,x:end_x),'all'));
    dy = int32(mean(flow.Vy(y:end_y,x:end_x),'all'));
    new_x = max(detected_bboxes(i,1) + dx, 1);
    new_x = min(new_x, length(frame));
    new_y = max(detected_bboxes(i,2) + dy, 1);
    new_y = min(new_y, height(frame));
    bbox(i,1) = new_x;
    bbox(i,2) = new_y;
end
end