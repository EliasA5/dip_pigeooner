clear all
clc

load("bounding_boxes.mat");


data_size = length(output.files);
%features_st = struct([]);
accumelated_features = [];

for i = 1:data_size
% for i = 1:10
    file_name  = output.files(i);
    img = imread(file_name);

    img = rgb2gray(img);
    bbox = output.bounding_boxes(i,:);
    
    points = detectSURFFeatures(img, "ROI", bbox, 'NumOctaves', 3,'NumScaleLevels', 3,'MetricThreshold',700);
    [features, ~] = extractFeatures(img,points);
    end_point = min(400, height(features));
    features = features(1:end_point, :);
    if(isempty(accumelated_features))
        accumelated_features = features;
        continue;
    end
    indexes = matchFeatures(accumelated_features, features);
    features(indexes(:,2), :) = [];
    accumelated_features = [accumelated_features; features];
%     ex_features = struct('features', features, 'validPoints', validPoints); 
%     features_st = [features_st ,ex_features];
end

save('extracted_features.mat', 'accumelated_features');
    %load('extracted_features.mat', 'features_st')



% figure()
% imshow(img);
% hold on;
% shape = insertShape(img,"Rectangle",bbox);
% imshow(shape)


% figure;
% imshow(img);
% hold on
% plot(points)

