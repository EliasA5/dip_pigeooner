close all;

load("bounding_boxes.mat");
load("extracted_features.mat");

params_uint8 = [105, 140, 5, 36, 179, 255];
params_old = params_uint8./255;
opticFlow = opticalFlowFarneback;
blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false,'MinimumBlobArea', 5000);
data_size = length(output.files);
range = 1:data_size;

time_color_old = zeros(size(range));
time_color_new = zeros(size(range));
time_median = zeros(size(range));
time_imfill = zeros(size(range));
time_optical_flow = zeros(size(range));
time_blobs = zeros(size(range));



for i=range
img = imread(output.files(i));
pigeon_img = imcrop(img, output.bounding_boxes(i, :));
pigeon_img_gray = rgb2gray(pigeon_img);


tic;
[mask1, score1] = segment_color_old(img, params_old(1),params_old(2),params_old(3),params_old(4),params_old(5),params_old(6), 1);
time_color_old(i) = toc;

tic;
[mask2, score2] = segment_color(img, params_uint8(1),params_uint8(2),params_uint8(3),params_uint8(4),params_uint8(5),params_uint8(6),1);
time_color_new(i) = toc;

tic; 
flow = estimateFlow(opticFlow,rgb2gray(img));
time_optical_flow(i) = toc;

tic;
mask = medfilt2((flow.Magnitude > 1), [5 5]);
time_median(i) = toc;

tic;
mask = imfill(mask, 8, 'holes');
time_imfill(i) = toc;

tic;
bbox = step(blobAnalysis, mask);
time_blobs(i) = toc;

end

avg_times = [mean(time_color_old); mean(time_color_new); mean(time_median);...
    mean(time_imfill); mean(time_optical_flow); mean(time_blobs)]
close all;

output_1 = load("testing_images/bounding_boxes1.mat");
output_1 = output_1.output;
output_2 = load("testing_images/bounding_boxes2.mat");
output_2 = output_2.output;
output_3 = load("testing_images/bounding_boxes3.mat");
output_3 = output_3.output;


isPige = zeros(1, length(output_1.files) + length(output_2.files) + length(output_3.files), 'logical');
fig = figure;
offset = 0;
for i=1:length(output_1.files)
    img = imread(append("testing_images/", output_1.files(i)));
    pigeon_img = imcrop(img, output_1.bounding_boxes(i, :));
    pigeon_img_gray = rgb2gray(pigeon_img);
    [res, text] = isPigeon(pigeon_img, pigeon_img_gray, accumelated_features, 105, 140, ...
    5, 36, 179, 255, 0.5, 0.5, 0.5, 10);
    isPige(i+offset) = res;
    subplot(1,2,1);imshow(img);
    subplot(1,2,2);imshow(pigeon_img);
    sgtitle(text);
    pause(1e-2);
    saveas(fig, append("output_jpg/", string(i+offset)), 'jpeg');
end
offset = offset + length(output_1.files);

for i=1:length(output_2.files)
    img = imread(append("testing_images/",output_2.files(i)));
    pigeon_img = imcrop(img, output_2.bounding_boxes(i, :));
    pigeon_img_gray = rgb2gray(pigeon_img);
    [res, text] = isPigeon(pigeon_img, pigeon_img_gray, accumelated_features, 105, 140, ...
    5, 36, 179, 255, 0.5, 0.5, 0.5, 10);
    isPige(i+offset) = res;
    subplot(1,2,1);imshow(img);
    subplot(1,2,2);imshow(pigeon_img);
    sgtitle(text);
    pause(1e-2);
    saveas(fig, append("output_jpg/", string(i+offset)), 'jpeg');
end
offset = offset + length(output_2.files);

for i=1:length(output_3.files)
    img = imread(append("testing_images/",output_3.files(i)));
    pigeon_img = imcrop(img, output_3.bounding_boxes(i, :));
    pigeon_img_gray = rgb2gray(pigeon_img);
    [res, text] = isPigeon(pigeon_img, pigeon_img_gray, accumelated_features, 105, 140, ...
    5, 36, 179, 255, 0.5, 0.5, 0.5, 10);
    isPige(i+offset) = res;
    subplot(1,2,1);imshow(img);
    subplot(1,2,2);imshow(pigeon_img);
    sgtitle(text);
    pause(1e-2);
    saveas(fig, append("output_jpg/", string(i+offset)), 'jpeg');
end

isPige
true_positive = sum(isPige, 'all') / numel(isPige)

%%false positives
output_false_1 = load("testing_images/bounding_boxes_false_1.mat");
output_false_1 = output_false_1.output;
isPige_false = zeros(1, length(output_false_1.files), 'logical');

offset = 0;
for i=1:length(output_false_1.files)
    img = imread(append("testing_images/",output_false_1.files(i)));
    pigeon_img = imcrop(img, output_false_1.bounding_boxes(i, :));
    pigeon_img_gray = rgb2gray(pigeon_img);
    [res, text] = isPigeon(pigeon_img, pigeon_img_gray, accumelated_features, 105, 140, ...
    5, 36, 179, 255, 0.5, 0.5, 0.5, 10);
    isPige_false(i+offset) = res;
    subplot(1,2,1);imshow(img);
    subplot(1,2,2);imshow(pigeon_img);
    sgtitle(text);
    pause(1e-2);
    saveas(fig, append("output_jpg/false_pos_", string(i+offset)), 'jpeg');
end

isPige_false
false_positive = sum(isPige_false, 'all') / numel(isPige_false)
