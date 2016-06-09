
%  Exploiting the Circulant Structure of Tracking-by-detection with Kernels
%
%  Main script for tracking, with a gaussian kernel.
%
%  Jo�o F. Henriques, 2012
%  http://www.isr.uc.pt/~henriques/

clear all
clc
close all
%choose the path to the videos (you'll be able to choose one with the GUI)
base_path = 'C:\Users\rams1\Desktop\Spring2016\CV\Projects\Project_3\Videos\';


%parameters according to the paper
padding = 1;					%extra area surrounding the target
output_sigma_factor = 1/16;		%spatial bandwidth (proportional to target)
sigma = 0.2;					%gaussian kernel bandwidth
lambda = 1e-2;					%regularization
interp_factor = 0.075;			%linear interpolation factor for adaptation
outtxt = [];
framenum = [];

%notation: variables ending with f are in the frequency domain.

%ask the user for the video
video_path = choose_video(base_path);
video_path = strcat(video_path,'imgs/');
if isempty(video_path), return, end  %user cancelled
[img_files, pos, target_sz, resize_image, ground_truth, video_path] = ...
	load_video_info(video_path);


%window size, taking padding into account
sz = floor(target_sz * (1 + padding));

%desired output (gaussian shaped), bandwidth proportional to target size
output_sigma = sqrt(prod(target_sz)) * output_sigma_factor;
[rs, cs] = ndgrid((1:sz(1)) - floor(sz(1)/2), (1:sz(2)) - floor(sz(2)/2));
y = exp(-0.5 / output_sigma^2 * (rs.^2 + cs.^2));
yf = fft2(y);

%store pre-computed cosine window
cos_window = hann(sz(1)) * hann(sz(2))';


time = 0;  %to calculate FPS
positions = zeros(numel(img_files), 2);  %to calculate precision

for frame = 1:numel(img_files),
	%load image
	im = imread([video_path img_files{frame}]);
	if size(im,3) > 1,
		im = rgb2gray(im);
	end
	if resize_image,
		im = imresize(im, 0.5);
	end
	
	tic()
	
	%extract and pre-process subwindow
	x = get_subwindow(im, pos, sz, cos_window);
	
	if frame > 1,
		%calculate response of the classifier at all locations
		k = dense_gauss_kernel(sigma, x, z);
		response = real(ifft2(alphaf .* fft2(k)));   %(Eq. 9)
		[YN,psr(frame-1),psr0(frame-1)] = PSR(response);
        psr(frame-1)
        if frame>3
            if YN==1
                pos = kalmanpredict(oldpos(frame-1,:),oldpos(frame-2,:));
            end
            framenum = [framenum, frame];
        end
		%target location is at the maximum response
		[row, col] = find(response == max(response(:)), 1);
		pos = pos - floor(sz/2) + [row, col];
	end
	
	%get subwindow at current estimated target position, to train classifer
	x = get_subwindow(im, pos, sz, cos_window);
	
	%Kernel Regularized Least-Squares, calculate alphas (in Fourier domain)
	k = dense_gauss_kernel(sigma, x);
	new_alphaf = yf ./ (fft2(k) + lambda);   %(Eq. 7)
	new_z = x;
	
	if frame == 1,  %first frame, train with a single image
		alphaf = new_alphaf;
		z = x;
	else
		%subsequent frames, interpolate model
		alphaf = (1 - interp_factor) * alphaf + interp_factor * new_alphaf;
		z = (1 - interp_factor) * z + interp_factor * new_z;
	end
	
	%save position and calculate FPS
    positions(frame,:) = pos;
	time = time + toc();
	
	%visualization
	rect_position = [pos([2,1]) - target_sz([2,1])/2, target_sz([2,1])];
    outtxt = [outtxt; rect_position];
	if frame == 1,  %first frame, create GUI
		figure('Name',['Tracker - ' video_path])
		im_handle = imshow(im, 'Border','tight', 'InitialMag',200);
    else
		try  %subsequent frames, update GUI
            if YN == 1
                combinedImage = insertObjectAnnotation(im, 'rectangle',...
                    rect_position, {'Predicted'}, 'Color', 'red');
            else
                combinedImage = insertObjectAnnotation(im, 'rectangle',...
                    rect_position, {'Detected'}, 'Color', 'green');
            end
            im_handle = imshow(combinedImage, 'Border','tight', 'InitialMag',200);
            
		catch  %#ok, user has closed the window
			return
		end
	end
	
	drawnow
    %pause(0.05)  %uncomment to run slower
    oldpos = positions;
end
writetable(table(outtxt),'OUR.txt');
[z,x]=find(psr<10); % important frames
if resize_image, positions = positions * 2; end

disp(['Frames-per-second: ' num2str(numel(img_files) / time)])

%show the precisions plot
show_precision(positions, ground_truth, video_path);