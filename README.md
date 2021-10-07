# Frame-differencing methods (FDMs) in video analysis: MATLAB script
Adapted Paxton & Dale's (2013) script for MATLAB. This adapted version allows researchers with minimal programming experience to execute automated analyses of interpersonal synchrony between two interlocutors. My primary contribution was to write a script for image segmentation, eliminating the need to do this with other software, and improve the usability of the FDM processing loop.

Paxton, A., & Dale, R. (2013). Frame-differencing methods for measuring bodily synchrony in conversation. *Behavior Research Methods, 45*(2), 329–343. https://doi.org/10.3758/s13428-012-0249-2

## What is Interpersonal Synchrony?

Individuals involved in an interaction (i.e., interlocutors) tend to coordinate and synchronize their movements. This finding is well-established across the behavioural sciences, and the proliferation of terms invoked by researchers (e.g., mimicry, coordination, interpersonal synchrony) reflect different approaches to measuring and analyzing synchrony.

The issues with synchrony data collection and analysis are manifold. Synchrony research often centers on the dyad rather than the individual (leading to smaller sample sizes), interactions unfold over minutes or hours, and the analysis of interactions for synchrony has traditionally required researchers to either hand-code movements in videotaped interactions frame-by-frame (a labour-intensive and time-consuming process), or compromise objectivity for efficiency by collecting holistic ratings of interlocutors instead of analyzing precise limb movements.

Automated video analysis presents one solution. Grounded in research indicating that dyads synchronize in posture, gestures, and overall body movement, frame-differencing methods (FDMs) encompass a variety of existing computer-based methods to track changes in pixels from one frame to the next. Similar to background subtraction/foreground detection techniques, the background of an image remains static, such that pixel changes are attributed only to interlocutors’ movement. Thus, FDMs analyze movement quantitatively, and have easy, cost-effective data collection setups – offering a powerful tool for studying synchrony. 

## Data Collection and Preparation

The data need to be in a video format supported by VideoReader. During data collection, we recommend using a video camera (preferably HD) mounted to be stable. The light source should remain relatively stable, although slight fluctuations (e.g., flickering fluorescent lights) are controlled for by the script using a second-order Butterworth low-pass filter. To minimize the monitoring that is required during analysis, participants should preferably be made to face each other, each occupying one half of the frame such that they are both equidistant from the center.

## Image Segmentation

The video needs to be uploaded to a computer and imported into MATLAB: this script provides the functionality to do so, and additionally segments the video by frame into image sequences. On line 39, input the name of the directory with the video file. On line 42, change the format of the video (for our demonstration, we use .m4v). The script then processes each frame of the video and writes individual frames to a subdirectory; each frame image is saved with a unique name. We chose to output image files as PNG files, but this can be changed on line 105.

## Processing Loop to Apply Frame-Differencing
The script then automatically switches the current directory to the newly created directory with the image files, and fetches the images. 
In order to measure synchrony, the script tracks changes in pixels from one frame to the next, applying background subtraction/foreground detection to each half of the frame to identify synchronized movement between the interlocutors. The images are vertically halved because each interlocutor’s movement constitutes each half of the 640x360 frame. If the halfway point for your video is different, or if your video is not 640x360, the halfway point must be defined on lines 150 and 155.

On line 150, which designates the first participant’s “region”, the first value (1:360) represents the range of pixels on the y-axis that should be read (our video height = 360px, so we read all of it), and the second value (1:320) designates the x-axis (our video width is 640px, so we halve it to obtain 320px).

On line 155, we use the same approach: the y-axis value does not change (video height), but the x-axis value is now 321:end to designate this as the participant on the right.

A second-order Butterworth low-pass filter is applied to each sequence of half-images. This allows us to maximize detection of movement (e.g., slight changes in posture) while minimizing the false detection of noise (e.g., lighting fluctuations in both halves of the frame).

## Calculating Cross-Correlation Coefficients (Interpersonal Synchrony)
The script then combines the standardized scores for the two sequences of half-images (i.e., the movement of each individual over time) to derive cross-correlation coefficients, which is our measure of synchrony. In signal processing research, cross-correlations measure the similarity between *X* and shifted (lagged) copies of *Y* as a function of time lag. In other words, what is the Pearson correlation coefficient between the two sequences of movements at various time lags? For example, a lag of 0 pairs participant A’s movement at time *t* with participant B’s movement at time *t* (they are in phase). A lag of +1 shifts one series by 1 frame, pairing A’s movement at time *t + 1* with B’s movement at *t*. At each lag, a correlation coefficient is calculated (line 178).

Critically, we compare the correlation (*r*) at various time lags to determine if interlocutors are moving in sync, or if one is leading/lagging behind the other. If *r* is highest closer to a lag of 0 (in phase) compared to lags of ±1/±2/±3/etc., this would indicate that participants’ movements are synchronized – changes in their movement coincide in time. Past researchers have recommended calculating *r* at each second within a window of ±3 s.

The variable lag_size (line 116) defines the time lag window. Here, lag_size = 150 because videos are typically 50-60 FPS, so 3 seconds x 50 frames = 150.

Although this value can be changed as needed, it’s important to then change line 192.

The script calculates *r* at each frame (not each second), so the loop on line 192 creates an *r* for each of ±150 frames (double the lag_size) – giving us 301 rows of coefficients, where the *r* for the exact time lag of 0 is row 151.

Row 201 is approximately the *r* at a time lag of +1 s, row 251 at +2 s, and row 301 at +3 s. Because the script also calculates negative time lag, rows 1-150 give us the *r* for up to -3 s.

## Output
The script generates a .csv file that can be renamed in line 188. Transpose and plot this data in your data management program of choice (Excel; see EXCEL_Transposehelper.txt).

As mentioned above, a value of 151 on the x axis indicates a time lag “true 0”. If *r* hovering around this value is larger in magnitude compared to *r* around various time lags (e.g., x=201, x=101, x=301), this would indicate greater synchrony.

## References
Paxton, A., & Dale, R. (2013). Frame-differencing methods for measuring bodily synchrony in conversation. *Behavior Research Methods, 45*(2), 329–343. https://doi.org/10.3758/s13428-012-0249-2


