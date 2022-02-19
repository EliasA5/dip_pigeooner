function [pigeon] = isPigeon(rgb_img, grey_img) %only cut images inside this func
    [~, segment_score] = segment_color(rgb_img);
    [~, feature_score] = feature_detect(grey_img);
    pigeon = (segment_score*0.7 + feature_score*0.3) > 0.5;
end