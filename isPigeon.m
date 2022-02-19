function [pigeon] = isPigeon(rgb_img, grey_img, accumelated_features) %only cut images inside this func
    [~, segment_score] = segment_color(rgb_img);
    [~, feature_score] = feature_detect(grey_img, accumelated_features);
%     fprintf('segment score: %lu, feature_score: %lu, overall_score: %lu\n', ...
%             segment_score, feature_score, (2*segment_score*0.7 + 50*feature_score*0.3));
    pigeon = (2*segment_score*0.7 + 50*feature_score*0.3) > 0.4;
end