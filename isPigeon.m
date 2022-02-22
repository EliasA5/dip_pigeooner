function [pigeon] = isPigeon(rgb_img, grey_img, accumelated_features,...
    h_min, h_max, s_min, s_max, v_min, v_max, score_dist, isPigeon_threshhold) %only cut images inside this func
    [~, segment_score] = segment_color(rgb_img, h_min, h_max, s_min, s_max, v_min, v_max);
    [counter, feature_score] = feature_detect(grey_img, accumelated_features);
    fprintf('segment score: %lu, feature_count: %lu, overall_score: %lu\n', ...
            segment_score, counter, (segment_score*score_dist + feature_score*(1-score_dist)));
    pigeon = (segment_score*score_dist + feature_score*(1-score_dist)) > isPigeon_threshhold;
end