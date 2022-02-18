function [mask, score] = segment_color(img)
mask = dip_find_pigeon(img);
score = sum(mask, 'all') / numel(mask);
end

function [filter] = dip_find_pigeon(img)
hsv = uint8(255*rgb2hsv(img));

cap_h = hsv(:,:,1);
cap_s = hsv(:,:,2);
cap_v = hsv(:,:,3);
 
cap_h_filt = (cap_h >= 140) & (cap_h <= 158); %140 158
cap_s_filt = (cap_s >= 25) & (cap_s <= 49); %25 49
cap_v_filt = (cap_v >= 179) & (cap_v <= 255); %179 255

% figure;
% subplot(1,3,1);imshow(cap_h_filt);title('h');
% subplot(1,3,2);imshow(cap_s_filt);title('s');
% subplot(1,3,3);imshow(cap_v_filt);title('v');

filter = cap_h_filt & cap_s_filt & cap_v_filt;
filter = imfill(filter, 4, 'holes');
filter = medfilt2(filter,[5 5]);

end