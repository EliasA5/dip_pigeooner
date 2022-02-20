
function main()
    %% 
    % Create a figure window and two axes to display the input video and the
    % processed video.
    [hFig, hAxes] = createFigureAndAxes();
    
    %%
    % Add buttons to control video playback.
    insertButtons(hFig, hAxes);
    
    %% Interact with the New User Interface
    % Now that the GUI is constructed, we can press the play button to trigger
    % the main video processing loop defined in the |getAndProcessFrame| function
    % listed below.
    % Initialize the display with the first frame of the video
    
    cam = webcam(1);
    cam.Resolution = string(cam.AvailableResolutions(6));
    cam.ExposureMode = 'auto';
    cam.WhiteBalanceMode = 'auto';
    
    rgb_frame = snapshot(cam);
    frame = rgb2gray(rgb_frame);
    [h_frame, len_frame] = size(frame);
    
    Predicted_bboxes = [];
    blobAnalysis = vision.BlobAnalysis('AreaOutputPort', false, 'CentroidOutputPort', false,'MinimumBlobArea', 5000);
    opticFlow = opticalFlowFarneback;
    threshhold = 3.5;
    
    % Display input video frame on axis
    showFrameOnAxis(hAxes.axis1, zeros(h_frame,len_frame));
    showFrameOnAxis(hAxes.axis2, zeros(h_frame,len_frame));
    showFrameOnAxis(hAxes.axis3, zeros(h_frame,len_frame));
    showFrameOnAxis(hAxes.axis4, zeros(h_frame,len_frame));
    
    %%
    % Note that each video frame is centered in the axis box. If the axis size
    % is bigger than the frame size, video frame borders are padded with
    % background color. If axis size is smaller than the frame size scroll bars
    % are added.
    
        function [hFig, hAxes] = createFigureAndAxes()
    
            % Create new figure
            hFig = figure('numbertitle', 'off', ...
                   'name', 'Pigeooner', ...
                   'menubar','none', ...
                   'toolbar','none', ...
                   'resize', 'on', ...
                   'renderer','painters', ...
                   'position',[50 50 1600 800],...
                   'HandleVisibility','callback'); % hide the handle to prevent unintended modifications of our custom UI
    
            % Create axes and titles
            hAxes.axis1 = createPanelAxisTitle(hFig,[0 0.5 0.5 0.5],'Webcam'); % [X Y W H]
            hAxes.axis2 = createPanelAxisTitle(hFig,[0.5 0.5 0.5 0.5],'Grey Frame');
            hAxes.axis3 = createPanelAxisTitle(hFig,[0 0 0.5 0.5],'Detected Movment'); % [X Y W H]
            hAxes.axis4 = createPanelAxisTitle(hFig,[0.5 0 0.5 0.5],'Detected pigeon');
            
        end
    
        function hAxis = createPanelAxisTitle(hFig, pos, axisTitle)
    
            % Create panel
            hPanel = uipanel('parent',hFig,'Position',pos,'Units','Normalized');
    
            % Create axis
            hAxis = axes('position',[0 0 1 1],'Parent',hPanel);
            hAxis.XTick = [];
            hAxis.YTick = [];
            hAxis.XColor = [1 1 1];
            hAxis.YColor = [1 1 1];
            % Set video title using uicontrol. uicontrol is used so that text
            % can be positioned in the context of the figure, not the axis.
            titlePos = [pos(1)+0.2 pos(2)+0.45 0.1 0.02];
            uicontrol('style','text',...
                'String', axisTitle,...
                'Units','Normalized',...
                'Parent',hFig,'Position', titlePos,...
                'BackgroundColor',hFig.Color);
        end
    
    %% Insert Buttons
    % Insert buttons to play, pause the videos.
        function insertButtons(hFig,hAxes)
    
            % Play button with text Start/Pause/Continue
            uicontrol(hFig,'unit','pixel','style','pushbutton','string','Start',...
                    'position',[10 10 75 25], 'tag','PBButton123','callback',...
                    {@playCallback,hAxes});
    
            % Exit button with text Exit
            uicontrol(hFig,'unit','pixel','style','pushbutton','string','Exit',...
                    'position',[100 10 50 25],'callback', ...
                    {@exitCallback,hFig});
        end     
    
    %% Play Button Callback
    % This callback function rotates input video frame and displays original
    % input video frame and rotated frame on axes. The function
    % |showFrameOnAxis| is responsible for displaying a frame of the video on
    % user-defined axis. This function is defined in the file
    % <matlab:edit(fullfile(matlabroot,'examples','vision','main','showFrameOnAxis.m')) showFrameOnAxis.m>
        function playCallback(hObject,~,hAxes)
           try
                % Check the status of play button
                isTextStart = strcmp(hObject.String,'Start');
                isTextCont  = strcmp(hObject.String,'Continue');
    
                if (isTextStart || isTextCont)
                    hObject.String = 'Pause';
                else
                    hObject.String = 'Continue';
                end
    
                while strcmp(hObject.String, 'Pause')
                    % Get input video frame and process each frame
    
                    [rgb_frame,frame,movement,~,~,pigeons,Predicted_bboxes] = getAndProcessFrame(cam,opticFlow,Predicted_bboxes,blobAnalysis,threshhold,h_frame,len_frame);
                    showFrameOnAxis(hAxes.axis1, rgb_frame);
                    showFrameOnAxis(hAxes.axis2, frame);
                    showFrameOnAxis(hAxes.axis3, movement);
                    showFrameOnAxis(hAxes.axis4, pigeons);
    
                end
                
           catch ME
               % Re-throw error message if it is not related to invalid handle 
               if ~strcmp(ME.identifier, 'MATLAB:class:InvalidHandle')
                   rethrow(ME);
               end
           end
        end
    
    
    %% Exit Button Callback
    % This callback function releases system objects and closes figure window.
        function exitCallback(~,~,hFig)
            
            close(hFig);
            clear cam;
    
        end
    
    
    end
    