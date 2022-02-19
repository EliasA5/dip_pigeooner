% % Test function 
% load("bounding_boxes.mat");
% 
% file_name  = output.files(2);
% img = rgb2gray( imread(file_name));
% temp = output.bounding_boxes(2,:);
% 
% 
% [features_num, score] = feature_detect(img, temp);

function [counter, score] = feature_detect(test_img)
% Detects matched features between training images and the test images
% (video), Gets a test image and the bounding box, returns the number of
% matched features and the score (number of features/overall features)

   load('extracted_features.mat', 'features_st');
   counter = 0;
   overall = 0;
   data_size = length(features_st);
   points_test = detectSURFFeatures(test_img, 'NumOctaves', 3,'NumScaleLevels', 3,'MetricThreshold',700);
   [features_test,validPoints_test] = extractFeatures(test_img,points_test);
   
   for i = 1:data_size
       features_train = features_st.features;
       validPoints_train = features_st.validPoints;
       overall = overall + validPoints_train.Count;

       indexPairs_test = matchFeatures(features_train, features_test);
       matched_points = validPoints_test(indexPairs_test(:,2));
       counter = counter + matched_points.Count;

   end
   score = counter/overall;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all
% clc
% 
% load("bounding_boxes.mat");
% 
% data_size = length(output.files);
% % features_st = zeros(data_size,1);
% 
% i = 1;
% % for :data_size
%     file_name  = output.files(i);
%     img = imread("img2.jpeg");
% 
%     img = rgb2gray(img);
%     bbox = output.bounding_boxes(i,:);
%     
%     points = detectSURFFeatures(img, 'NumOctaves', 5,'NumScaleLevels', 3,'MetricThreshold',500);
%     [features,validPoints] = extractFeatures(img,points);
% %     ex_features = struct('features', features, 'validPoints', validPoints); 
%     %%features_st(i) = ex_features;
% 
%     % How to save data to file?? 
%     %save('extracted_features.mat', 'features_st');
%     %load('extracted_features.mat', 'features_st')
% 
% % gray = rgb2gray( imread(output.files(14)));
% gray = rgb2gray( imread("PXL_20220215_130332655.jpg"));
% 
% points1 = detectSURFFeatures(gray, 'NumOctaves', 5,'NumScaleLevels', 3,'MetricThreshold',500);
% [features1,validPoints1] = extractFeatures(gray,points1);
% indexPairs = matchFeatures(features, features1);
% % indexPairs = matchFeatures(features, features1,'MatchThreshold',1.5,'MaxRatio',1);
% 
% matched_points1 = validPoints1(indexPairs(:,2));
% matched_points2 = validPoints(indexPairs(:,1));
% figure; showMatchedFeatures(img,gray,matched_points2,matched_points1,'montage');
% legend('matched points 1','matched points 2');
% 
% 
% % figure()
% % imshow(img);
% % hold on;
% % shape = insertShape(img,"Rectangle",bbox);
% % imshow(shape)
% 
% 
% % figure;
% % imshow(img);
% % hold on
% % plot(points)
% 
