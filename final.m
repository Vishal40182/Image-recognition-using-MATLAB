tic; % Start timer.
clc; % Clear command window.
clearvars;
fprintf('Running BlobsDemo.m...\n'); % Message sent to command window.
matrix1 = zeros(100,7);
% matrix1(1,:) = ["k" "meanGL" "blobArea" "blobAreaPercentage" "blobPerimeter" "blobCentroid" "blobECD(k)"]
matrix2 = zeros(100,7);
% matrix2(1,:) = ["k" "meanGL" "blobArea" "blobAreaPercentage" "blobPerimeter" "blobCentroid" "blobECD(k)"]

for j = 1 : 100
	
	% OPTION 2: Create an image filename, and read it in to a variable called imageData.
	pngFileName = strcat( num2str(j), '.png');
	if isfile(pngFileName)
		
	

originalImage = imread(pngFileName);
[rows, columns, numberOfColorChannels] = size(originalImage);
	originalImage = rgb2gray(originalImage);

% axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.

% grid on;

thresholdValue = 100;
binaryImage = originalImage > thresholdValue; % Bright objects will be chosen if you use >.
% ========== IMPORTANT OPTION ============================================================
% Use < if you want to find dark objects instead of bright objects.
%   binaryImage = originalImage < thresholdValue; % Dark objects will be chosen if you use <.
% Do a "hole fill" to get rid of any background pixels or "holes" inside the blobs.
binaryImage = imfill(binaryImage, 'holes');

labeledImage = bwlabel(binaryImage, 8);     % Label each blob so we can make measurements of it

coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
% coloredLabels is an RGB image.  We could have applied a colormap instead (but only with R2014b and later)

blobMeasurements = regionprops(labeledImage, originalImage, 'all');
numberOfBlobs = size(blobMeasurements, 1);

boundaries = bwboundaries(binaryImage);
numberOfBoundaries = size(boundaries, 1);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
% 	plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
end

blobECD = zeros(1, numberOfBlobs);

fprintf(1,'Blob #      Mean Intensity  Area   blobAreaPercentage    Perimeter    Centroid       Diameter\n');
% Loop over all blobs printing their measurements to the command window.

t = 0:0.0005:0.03;


for k = 1 : numberOfBlobs           % Loop through all blobs.
	% Find the mean of each blob.  (R2008a has a better way where you can pass the original image
	% directly into regionprops.  The way below works for all versions including earlier versions.)
	
    
    thisBlobsPixels = blobMeasurements(k).PixelIdxList;  % Get list of pixels in current blob.
	meanGL = mean(originalImage(thisBlobsPixels)); % Find mean intensity (in original image!)
	meanGL2008a = blobMeasurements(k).MeanIntensity; % Mean again, but only for version >= R2008a
	
	time = t(1,j);
    blobAreaPixel = blobMeasurements(k).Area;		% Get area.
	blobAreaPercentage = 100*(blobAreaPixel/(size(originalImage,1)*size(originalImage,2)));
    Area = (blobAreaPixel*128/(size(originalImage,1)*size(originalImage,2)))
    blobPerimeter = blobMeasurements(k).Perimeter;		% Get perimeter.
	blobCentroid = blobMeasurements(k).Centroid;		% Get centroid one at a time
	blobECD(k) = sqrt(4 * blobAreaPixel / pi);					% Compute ECD - Equivalent Circular Diameter.
	fprintf(1,'#%2d %17.1f %11.1f %11.1f %18.1f %8.1f %8.1f % 8.1f\n', k, meanGL, blobAreaPixel, blobAreaPercentage, blobPerimeter, blobCentroid, blobECD(k));
	% Put the "blob number" labels on the "boundaries" grayscale image.
	
    if k == 1
%         a(k,:) = [meanGL blobArea blobAreaPercentage blobPerimeter blobCentroid blobECD(k)];
%         matrix1(j+1,:) = a;
        
        p = table(k,time, meanGL, blobAreaPixel, blobAreaPercentage, Area, blobPerimeter, blobCentroid, blobECD(k))
        table1(j,:) = p
        
    elseif k == 2
%         b(k-1,:) = [meanGL blobArea blobAreaPercentage blobPerimeter blobCentroid blobECD(k)];
%         matrix2(j+1,:) = b;
        
        q = table(k,time, meanGL, blobAreaPixel, blobAreaPercentage, Area, blobPerimeter, blobCentroid, blobECD(k))
        table2(j,:) = q
        
    end
end
    else
        
%        fprintf('File %s does not exist.\n', pngFileName);

        break
    end
	
	
end

writetable(table1,"upperbubble.csv")
writetable(table2,"lowerBubble.csv")

% writematrix(matrix1,'upperBubble.csv') 
% writematrix(matrix2,'lowerBubble.csv')