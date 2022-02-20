function [rgb_frame,frame,movement,flow,mask,pigeons,Predicted_bboxes] = ProcessFrame(cam,opticFlow,Predicted_bboxes,blobAnalysis,threshhold,h_frame,len_frame)
    
    rgb_frame = snapshot(cam);
    frame = rgb2gray(rgb_frame);
    
    flow = estimateFlow(opticFlow,frame);
    
    mask = medfilt2((flow.Magnitude > threshhold), [5 5]);
    mask = imfill(mask, 'holes');
    
    bbox = step(blobAnalysis, mask);
    
    
    movement = frame;
    movement(~mask) = 0;
    
    
    Predicted_bboxes = remove_overlap([Predicted_bboxes; bbox]);
    
    % for i = height(Predicted_bboxes):-1:1
    %     x = Predicted_bboxes(i,1);
    %     y = Predicted_bboxes(i,2);
    %     end_x = min(x+Predicted_bboxes(i,3),len_frame);
    %     end_y = min(y+Predicted_bboxes(i,4),h_frame);
    %     pigeon = isPigeon(rgb_frame(y:end_y,x:end_x, :), frame(y:end_y,x:end_x), accumelated_features);
    %     if(~pigeon)
    %         Predicted_bboxes(i,:) = [];
    %     end
    % end
    
    pigeons = insertShape(frame, 'Rectangle', Predicted_bboxes, 'Color', 'red', 'LineWidth', 3);
    
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
    
    end
    
    
    
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
    