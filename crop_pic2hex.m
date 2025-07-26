% Hexagon Crop Script
% Reads a JPG image, crops it to a hexagon shape, and saves the result.

% ---- User Parameters ----
% Automatically locate the user's Downloads folder
if ispc
    userHome = getenv('USERPROFILE');
else
    userHome = getenv('HOME');
end

filename    = 'image.jpg';             % change to your actual filename
inputFile   = fullfile(userHome, 'Downloads', filename);
outputFile  = fullfile(userHome, 'Downloads', 'output_hexagon.png');

if ~isfile(inputFile)
    error('Input file not found: %s', inputFile);
end

% ---- Read Image ----
img = imread(inputFile);
[H, W, C] = size(img);

% ---- Define Hexagon ----
cx = W/2;         % center x-coordinate
cy = H/2;         % center y-coordinate
r  = min(W, H)/2; % radius of circumscribed circle

% Generate 6 vertices around the circle
angles = linspace(0, 2*pi, 7);
xv = cx + r * cos(angles(1:end-1));
yv = cy + r * sin(angles(1:end-1));

% Create a binary mask of the hexagon
mask = poly2mask(xv, yv, H, W);

% ---- Apply Mask ----
% Prepare output image with white background outside hexagon
outRGB = uint8(zeros(H, W, 3));
for ch = 1:3
    band = img(:,:,ch);
    band(~mask) = 255; % white background
    outRGB(:,:,ch) = band;
end

stats = regionprops(mask, 'BoundingBox');
bb = stats.BoundingBox;
x = floor(bb(1));
y = floor(bb(2));
w = ceil(bb(3));
h = ceil(bb(4));
croppedRGB = imcrop(outRGB, [x, y, w, h]);

maskCrop = imcrop(mask, [x, y, w, h]);
alphaChannel = uint8(maskCrop * 255);
imwrite(croppedRGB, outputFile, 'Alpha', alphaChannel);

fprintf('Hexagon-cropped image saved to %s\n', outputFile);
