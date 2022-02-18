close all
%clc

img = imread('PXL_20220215_130251541.jpg');
img_hsv = rgb2hsv(img);

figure;
subplot(1,3,1);imshow(img_hsv(:,:,1));title('h');colorbar;
subplot(1,3,2);imshow(img_hsv(:,:,2));title('s');colorbar;
subplot(1,3,3);imshow(img_hsv(:,:,3));title('v');colorbar;

tic;[mask, score] = segment_color(img);toc;

figure;imshow(mask);title('color segmented');