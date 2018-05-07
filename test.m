% Create the face detector object.
faceDetector = vision.CascadeObjectDetector();

loadData = 0;

if loadData
    classifier = load('model.mat');
    conf = load('conf.mat');
end

% Create the webcam object.
cam = webcam();

% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);

% Create the video player object.
videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(videoFrame, 2), size(videoFrame, 1)]+30]);

runLoop = true;
numPts = 0;
frameCount = 0;

while runLoop && frameCount < 400

    % Get the next frame.
    videoFrame = snapshot(cam);
    videoFrameGray = rgb2gray(videoFrame);
    frameCount = frameCount + 1;

%     Detection mode.
    bbox = faceDetector.step(videoFrameGray);
    
%     if ~isempty(bbox)
%         bbox = bbox(1, :);
%         img = videoFrameGray(bbox(2):bbox(2)+bbox(4), bbox(1):bbox(1)+bbox(3));
%         features = getImageDescriptor(conf.conf, img);
        
%         % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
%         % format required by insertShape.
%         bboxPolygon = reshape(bboxPoints', 1, []);
% 
%         % Display a bounding box around the detected face.
%         videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
%     end


    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);

    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
end

% Clean up.
clear cam;
release(videoPlayer);
release(faceDetector);