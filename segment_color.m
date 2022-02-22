function [mask, score] = segment_color(img, h_min, h_max, s_min, s_max, v_min, v_max , ratio)
mask = dip_find_pigeon(img, h_min, h_max, s_min, s_max, v_min, v_max);
score = min(1,sum(mask, 'all') /  (ratio * numel(mask)));
end

function [filter] = dip_find_pigeon(img, h_min, h_max, s_min, s_max, v_min, v_max)
hsv = uint8(255*rgb2hsv(img));

cap_h = hsv(:,:,1);
cap_s = hsv(:,:,2);
cap_v = hsv(:,:,3);
% figure;
% subplot(2,3,4);imshow(cap_h);title('h');
% subplot(2,3,5);imshow(cap_s);title('s');
% subplot(2,3,6);imshow(cap_v);title('v');

cap_h_filt = (cap_h >= h_min) & (cap_h <= h_max); %140 158
cap_s_filt = (cap_s >= s_min) & (cap_s <= s_max); %25 49
cap_v_filt = (cap_v >= v_min) & (cap_v <= v_max); %179 255


% subplot(2,3,1);imshow(cap_h_filt);title('h');
% subplot(2,3,2);imshow(cap_s_filt);title('s');
% subplot(2,3,3);imshow(cap_v_filt);title('v');

filter = (cap_h_filt & cap_s_filt) | (cap_h_filt & cap_v_filt) | (cap_s_filt & cap_v_filt);
%filter = (cap_h_filt & cap_s_filt & cap_v_filt) ;
filter = imfill(filter, 4, 'holes');
filter = medfilt2(filter,[5 5]);

end