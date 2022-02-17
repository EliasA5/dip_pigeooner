clear all
clc

load("bounding_boxes.mat");


data_size = length(output.files);
features_st = struct([]);

for i = 1:data_size
% for i = 1:10
    file_name  = output.files(i);
    img = imread(file_name);

    img = rgb2gray(img);
    bbox = output.bounding_boxes(i,:);
    
    points = detectSURFFeatures(img, "ROI", bbox, 'NumOctaves', 3,'NumScaleLevels', 3,'MetricThreshold',700);
    [features,validPoints] = extractFeatures(img,points);
    ex_features = struct('features', features, 'validPoints', validPoints); 
    features_st = [features_st ,ex_features];

end

save('extracted_features.mat', 'features_st');
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

