close all;
clear vars;
clc;

load('extracted_features.mat', 'accumelated_features');

% cam = webcam(1);
% cam.Resolution = string(cam.AvailableResolutions(6));
% cam.ExposureMode = 'auto';
% cam.WhiteBalanceMode = 'auto';



blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false, 'MinimumBlobArea', 600);

opticFlow = opticalFlowFarneback;
threshhold = 1.5;

Predicted_bboxes = [];

filename = "3";
vidReader = VideoReader(append(filename,".mp4"));
vidWriter = VideoWriter(append("out_",filename));
open(vidWriter);


rgb_frame = imresize(readFrame(vidReader), 1/3);
frame = rgb2gray(rgb_frame);
flow = estimateFlow(opticFlow,frame);
[h_frame, len_frame] = size(frame);


figure;
while(hasFrame(vidReader))
tic
pause(0.04);%
rgb_frame = imresize(readFrame(vidReader), 1/3);
%rgb_frame = snapshot(cam);

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
Predicted_bboxes = remove_overlap([Predicted_bboxes; bbox]);

for i = height(Predicted_bboxes):-1:1
    x = Predicted_bboxes(i,1);
    y = Predicted_bboxes(i,2);
    end_x = min(x+Predicted_bboxes(i,3),len_frame);
    end_y = min(y+Predicted_bboxes(i,4),h_frame);
    pigeon = isPigeon(rgb_frame(y:end_y,x:end_x, :), frame(y:end_y,x:end_x), accumelated_features);
    if(~pigeon)
        Predicted_bboxes(i,:) = [];
    end
end

result = insertShape(frame, 'Rectangle', Predicted_bboxes, 'Color', 'green', 'LineWidth', 3);
subplot(2,2,4); imshow(result);

for i = 1:height(Predicted_bboxes)
    x = Predicted_bboxes(i,1);
    y = Predicted_bboxes(i,2);
    end_x = min(x+Predicted_bboxes(i,3),len_frame);
    end_y = min(y+Predicted_bboxes(i,4),h_frame);
    dx = int32(mean(flow.Vx(y:end_y,x:end_x),'all'));
    dy = int32(mean(flow.Vy(y:end_y,x:end_x),'all'));
    new_x = max(Predicted_bboxes(i,1) + dx, 1);
    new_x = min(new_x, len_frame);
    new_y = max(Predicted_bboxes(i,2) + dy, 1);
    new_y = min(new_y, h_frame);
    Predicted_bboxes(i,1) = new_x;
    Predicted_bboxes(i,2) = new_y;
end

writeVideo(vidWriter, result);
toc
end

close(vidWriter);
close all;

function [bboxes] = remove_overlap(bbox)
if height(bbox) < 2
    bboxes = bbox;
else
overlap_ratio = bboxOverlapRatio(bbox,bbox,"Min");
N=size(overlap_ratio,1);
overlap_ratio(tril(ones(N))==1) = 0;
overlap_bool = overlap_ratio > 0.5;
idx = any(overlap_bool,2);
bboxes = bbox(~idx,:);
end

end

