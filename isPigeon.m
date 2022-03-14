function [pigeon, text] = isPigeon(rgb_img, grey_img, accumelated_features,...
    h_min, h_max, s_min, s_max, v_min, v_max, score_dist, isPigeon_threshhold , area_ratio , feature_count) %only cut images inside this func
    [~, segment_score] = segment_color(rgb_img, h_min, h_max, s_min, s_max, v_min, v_max , area_ratio);
    [~, feature_score] = feature_detect(grey_img, accumelated_features,feature_count);
    overall_score = (segment_score*score_dist + feature_score*(1-score_dist));
    text = sprintf('segment score: %2.3f, feature score: %2.3f, overall score: %2.3f\n', ...
            segment_score, feature_score, overall_score);
    pigeon = overall_score >= isPigeon_threshhold;
end