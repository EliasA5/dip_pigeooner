function [mask, score] = segment_color(img)
mask = dip_find_pigeon(img);
score = sum(mask, 'all') / numel(mask);
end

function [filter] = dip_find_pigeon(img)
hsv = single(rgb2hsv(img));
cap_h = hsv(:,:,1);
cap_s = hsv(:,:,2);
cap_v = hsv(:,:,3);
 
cap_h_filt = zeros(size(cap_h), 'logical');
cap_s_filt = zeros(size(cap_s), 'logical');
cap_v_filt = zeros(size(cap_v), 'logical');
cap_h_filt((cap_h >= 0.55) & (cap_h <= 0.62)) = 1;
cap_s_filt((cap_s >= 0.1) & (cap_s <= 0.19)) = 1;
cap_v_filt((cap_v >= 0.7) & (cap_v < 1)) = 1;


% figure;
% subplot(1,3,1);imshow(cap_h_filt);title('h');
% subplot(1,3,2);imshow(cap_s_filt);title('s');
% subplot(1,3,3);imshow(cap_v_filt);title('v');


filter = cap_h_filt & cap_s_filt & cap_v_filt;
filter = imfill(filter, 4, 'holes');
filter = medfilt2(filter,[5 5]);


end