function [mask, score] = segment_color_old(img, h_min, h_max, s_min, s_max, v_min, v_max , ratio)
mask = dip_find_pigeon(img, h_min, h_max, s_min, s_max, v_min, v_max);
score = min(1,sum(mask, 'all') /  (ratio * numel(mask)));
end

function [filter] = dip_find_pigeon(img, h_min, h_max, s_min, s_max, v_min, v_max)
hsv = single(rgb2hsv(img));
cap_h = hsv(:,:,1);
cap_s = hsv(:,:,2);
cap_v = hsv(:,:,3);

cap_h_filt = zeros(size(cap_h));
cap_s_filt = zeros(size(cap_s));
cap_v_filt = zeros(size(cap_v));
cap_h_filt((cap_h >= h_min) & (cap_h <= h_max)) = 1;
cap_s_filt((cap_s >= s_min) & (cap_s <= s_max)) = 1;
cap_v_filt((cap_v >= v_min) & (cap_v < v_max)) = 1;


% figure;
% subplot(1,3,1);imshow(cap_h_filt);title('h');
% subplot(1,3,2);imshow(cap_s_filt);title('s');
% subplot(1,3,3);imshow(cap_v_filt);title('v');


filter = (cap_h_filt & cap_s_filt) | (cap_h_filt & cap_v_filt) | (cap_s_filt & cap_v_filt);
filter = imfill(filter, 4, 'holes');
filter = medfilt2(filter,[5 5]);

end