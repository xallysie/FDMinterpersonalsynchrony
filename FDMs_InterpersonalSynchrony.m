clc
clear all
close all
imtool close all
fontSize = 22

%% Frame-differencing methods in video analysis: A MATLAB script to measure bodily synchrony

% Based on frame-differencing methods (FDMs), this script allows users to
% execute automated analyses of bodily synchrony between two interlocutors.
% The script tracks changes in pixels from one frame to the next, applying
% background subtraction/foreground detection to each half of the frame to
% detect synchronized movement between the interlocutors. The script then
% combines the standardized scores for the two sequences of half-images
% (i.e., the movement of each individual within the dyad) to derive
% cross-correlation coefficients at various time lags, which is our measure
% of interpersonal synchrony. For example, if r, the correlation
% coefficient for interpersonal synchrony, is highest at a time lag of "0"
% relative to a time lag of +1/+2/+3/etc, this would indicate that the
% interlocutors have high bodily synchrony -- changes in their movement
% coincide in time. 

% This script enables us to examine bodily synchrony as well as leading/
% lagging behaviour. However, it currently does not include functionality
% for examining different behaviours (e.g., smiling versus frowning) or
% directionality of movement (e.g., leaning towards each other versus
% leaning away). Users with moderate programming expertise can adapt the
% script to include additional functions.

% The script has three sections: (1) segmentation of videos into image
% frames, (2) processing loop that filters and stores difference vectors
% between the images, and (3) calculation of correlation coefficients
% between paired images.


%% IMAGE SEGMENTATION % IMAGE SEGMENTATION % IMAGE SEGMENTATION %

% Set directory
cd 'C:\Users\USER\FOLDER_WITH_VIDEO_FILES'

% List all video (.m4v) files in directory
files = dir('*.m4v');

% Get name of folder that we're working with
folder = fileparts(which(files.name));

% Get full file name of video
vidFullFileName = fullfile(folder, files.name);

% Read in the video
V = VideoReader(vidFullFileName);

% Determine # of frames and dimensions of video
numberOfFrames = V.NumberOfFrames;
vidHeight = V.Height;
vidWidth = V.Width;
numberOfFramesWritten = 0;

% Prepare a figure to show the images in the upper half of the screen.
figure;
screenSize = get(0,'ScreenSize');
% Enlarge figure to full screen.
set(gcf, 'units','pixels','outerposition',[640 360 vidWidth+200 vidHeight+187]);
% the +200 and +187 correction makes the images the same size as the
% original video.

% Write individual frames to disk
    writeToDisk = true;
    
    % Extract out the various parts of the filename.
    [folder, baseFileName, extensions] = fileparts(vidFullFileName);
    
    % Make up a special new output subfolder for all the separate image
    % frames that we're extracting and saving to disk.
    folder = pwd; % Make it a subfolder of the folder where this m-file lives
    outputFolder = sprintf('%s/Movie Frames from %s', folder, baseFileName);
    
    % Create the folder if it doesn't already exist
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end

% Loop through the video, writing all frames out
% each frame will be saved as a separate file with a unique name

for frame = 1 : numberOfFrames
    % Extract the frame from the movie structure.
    thisFrame = read(V, frame);
    
    % Display it in figure
    himage = subplot(1, 1, 1);
    image(thisFrame);
    caption = sprintf('Frame %4d of %d.', frame, numberOfFrames);
	title(caption, 'FontSize', fontSize);
    drawnow; % Force the figure window to refresh.
    
    % Write the image array to the output file
    if writeToDisk
        % Construct an output image file name
        outputBaseFileName = sprintf('Frame %4.4d.png', frame);
        outputFullFileName = fullfile(outputFolder, outputBaseFileName);

        % Extract the image
        frameOutput = getframe(gca);
        imwrite (frameOutput.cdata, outputFullFileName, 'png');
    end
end

%% PROCESSING LOOP % PROCESSING LOOP % PROCESSING LOOP % PROCESSING LOOP %

% insert appropriate directory below
cd(outputFolder);

% basic variables
h = gcf;
lag_size = 150; %This tells 
%%
% fetch images
imgpath = 'Frame *.png';
imgfiles = dir(imgpath);
disp(['Found ' int2str(length(imgfiles)) ' image files.'])
%%
% create vectors for differenced image z-scores and L/R movement scores
image_z_diffs = [];
pLms = [];
pRms = [];
%%
% begin loop through images
for j=2:length(imgfiles)
    disp(['Processing image: ' int2str(j) '.']);
    % prep the files
    file_name = imgfiles(j).name;
    image_2 = imread(file_name);
    file_name = imgfiles(j-1).name;
    image_1 = imread(file_name);
    
    % collapse images across color
    image_2 = mean(image_2,3);
    image_1 = mean(image_1,3);
    
    % turn images into pixel z-scores
    image_2 = (image_2 - mean(image_2(:)))./std(double(image_2(:)));
    image_1 = (image_1 - mean(image_1(:)))./std(double(image_1(:)));
    
    % difference, standardize, and store difference vectors
    image_diff = abs(image_2 - image_1);
    image_z_diffs = [image_z_diffs ; mean(image_diff(:))];
    
    % split images into L/R
    pLm = mean(mean(mean(image_diff(1:360,1:320)))); % change pixels as needed 
    % to half image; first colon in image_diff designates y-axis range,
    % second colon designates x-axis range.
    % Since we're only splitting images into L/R, but we keep the full
    % range of y-axis values for both
    pRm = mean(mean(mean(image_diff(1:360,321:end)))); % see above
    
    % store split vectors
    pLms = [pLms ; pLm];
    pRms = [pRms ; pRm];
end
%%
% apply Butterworth filter to results
[bb,aa] = butter(2,.2);
pLms = filter(bb,aa,pLms);
pRms = filter(bb,aa,pRms);
% save workspace
save sample_FDM.mat;
disp('Frame-Differencing for Sample Dyad Complete.')


%% CALCULATE CORRELATIONS % CALCULATE CORRELATIONS % CALCULATE CORRELATIONS %

% create matrix for correlations
dy_xcorrs = [];
disp('Creating Correlations for Sample Dyad.')

% cross-correlate and fill matrix
dy_xcorr = xcov(pLms,pRms,lag_size,'coeff');
dy_xcorrs = [dy_xcorrs dy_xcorr];
disp('Cross-Correlation for Sample Dyad Complete.')
% save workspace
save sample_FDM.mat
disp('MATLAB Workspace Saved.')

%% GENERATE TEXT FILE % GENERATE TEXT FILE % GENERATE TEXT FILE %
% create csv file
delete('FDM.csv');
data_out = fopen('FDM.csv ','w');
disp('Text File Created.')

% fill the file with data
for corr=1:301
% insert cross-correlation coefficient calculated above
fprintf(data_out,'%d,',eval(['dy_xcorrs(' int2str(corr) ')']));
% add time slice (i.e., where along +/- 3s each coefficient was derived)
fprintf(data_out,'%d,',corr);
end
% close the data file
fclose(data_out);
disp('Text File Complete.');
