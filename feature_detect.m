
function [counter,score] = feature_detect(test_img, accumelated_features,feature_count)
% Detects matched features between training images and the test images
% (video), Gets a test image and the bounding box, returns the number of
% matched features and the score (number of features/overall features)
    %global accumelated_features;
   
   points_test = detectSURFFeatures(test_img, 'NumOctaves', 3,'NumScaleLevels', 3,'MetricThreshold',700);
   [features_test, ~] = extractFeatures(test_img,points_test);
   indexPairs_test = matchFeatures(accumelated_features, features_test);
   counter = height(indexPairs_test);
   score = min(1,counter/feature_count);
end

