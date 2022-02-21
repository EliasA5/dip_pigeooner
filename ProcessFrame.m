function [result, expected_bboxes, frames_count] = ...
            ProcessFrame(cam, opticFlow, expected_bboxes, frames_count,...
            blobAnalysis, threshhold, h_frame, len_frame, score_dist, isPigeon_threshhold, figure_selector)
    rgb_frame = snapshot(cam);
    frame = rgb2gray(rgb_frame);
    flow = estimateFlow(opticFlow,frame);

    mask = imfill(medfilt2((flow.Magnitude > threshhold), [5 5]), 'holes');

    bbox = step(blobAnalysis, mask);

    %check if object inside bbox is pigeon, remove entry if not

    for i=1:height(bbox)
        %check every box
        tmp_bbox = bbox(i,:);

        starty = tmp_bbox(2);endy = min(tmp_bbox(2)+tmp_bbox(4), h_frame);
        startx = tmp_bbox(1); endx = min(tmp_bbox(1)+tmp_bbox(3), len_frame);
        pigeon = isPigeon(rgb_frame(starty:endy,startx:endx, :), frame(starty:endy,startx:endx), accumelated_features...
            ,h_min, h_max, s_min, s_max, v_min, v_max, score_dist, isPigeon_threshhold);
        
        if(~pigeon), continue; end %tmp_bbox(3)*tmp_bbox(4)*3 > numel(frame) || 
        if(isempty(expected_bboxes)), expected_bboxes = [tmp_bbox]; frames_count = [0]; continue; end
        to_del = bboxOverlapRatio(tmp_bbox, expected_bboxes, 'min') > 0.4;
        expected_bboxes(to_del, :) = [];
        frames_count(to_del) = [];
        expected_bboxes = [expected_bboxes; tmp_bbox];
        frames_count = [frames_count; 0];
    end

    to_del = zeros(height(expected_bboxes),1, 'logical');
    for index=1:height(expected_bboxes)
        startx = expected_bboxes(index, 1);
        endx = min(expected_bboxes(index, 1)+expected_bboxes(index, 3), length(frame));
        starty = expected_bboxes(index, 2);
        endy = min(expected_bboxes(index, 2)+expected_bboxes(index, 4), height(frame));
        dx = int32(mean(flow.Vx(starty: endy, startx:endx), 'all'));
        dy = int32(mean(flow.Vy(starty: endy, startx:endx), 'all'));
        expected_bboxes(index, 1) = expected_bboxes(index, 1) + 1.32*dx;
        expected_bboxes(index, 2) = expected_bboxes(index, 2) + 1.32*dy;
        if(expected_bboxes(index, 1) < 1 ||  (expected_bboxes(index, 1)+expected_bboxes(index, 3)) > length(frame) ||...
                expected_bboxes(index, 2) < 1 || (expected_bboxes(index, 2)+expected_bboxes(index, 4)) > height(frame))
            to_del(index) = 1;
        elseif(dx == 0 && dy == 0)
            frames_count(index) = frames_count(index) + 1;
            if(frames_count > 10)
                starty = expected_bboxes(index,2);endy = min(expected_bboxes(index,2)+expected_bboxes(index,4), h_frame);
                startx = expected_bboxes(index,1); endx = min(expected_bboxes(index,1)+expected_bboxes(index,3), len_frame);
                pig = isPigeon(rgb_frame(starty:endy,startx:endx, :), frame(starty:endy,startx:endx), accumelated_features...
                    , h_min, h_max, s_min, s_max, v_min, v_max, score_dist, isPigeon_threshhold);
                if(~pig), to_del(index) = 1; end
            end
        end
    end
    expected_bboxes(to_del, :) = [];
    frames_count(to_del) = [];

    switch figure_selector
        case  'Detector'
            result = insertShape(frame, 'Rectangle', expected_bboxes, 'Color', 'green', 'LineWidth', 3);
        case 'Mask'
            result = mask;
        case 'Color Segmentation'
            [result, ~] = segment_color(rgb_frame, h_min, h_max, s_min, s_max, v_min, v_max);
    end
end
    