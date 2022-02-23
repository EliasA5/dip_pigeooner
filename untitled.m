
cam = webcam('Microsoft');
cam.Resolution = '640x360';
cam.WhiteBalanceMode = 'manual';
cam.ExposureMode = 'manual';
cam.Exposure = -7;
cam.Saturation = 50;
cam.Sharpness = 50;
cam.Brightness = 50;
preview(cam);


points = detectSURFFeatures(rgb2gray(img));
figure
imshow(img); hold on;
plot(points)
