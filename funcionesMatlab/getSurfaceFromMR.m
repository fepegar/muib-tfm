function [mrVras, mrF] = getSurfaceFromMR(img, roiRAS, simplify, n)

mr = imnorm(img.pixelData);

%% ROI calculation
roiVoxels = roiRAS2roiIJK(roiRAS, img);
dimImg = size(mr);
for dimension = 1:3
    ranges{dimension} = max(roiVoxels(1,dimension), 1) : min(roiVoxels(2,dimension), dimImg(dimension));
end


%% Thresholding
thresh = 0.0264; %%%%%%% if binary, these parameters don't matter
mrMask = mr > thresh;
mrMask = imopen(mrMask, ones(3,3,3));
mrMask = imclose(mrMask, ones(3,3,3));


%% Fill holes
mrMask = bwareaopen(mrMask, 100000); %%%%%%%% largestregion mas robusto
mrMask = fillholes3d(mrMask, 2); %%%%%%%%%


%% Mesh generation
if nargin > 2
    [mrV, mrF] = myvol2surf(mrMask,ranges,simplify, n);
else
    [mrV, mrF] = myvol2surf(mrMask,ranges);
end

%% Crop mesh
[mrV, mrF] = cropMesh(mrV, mrF, roiVoxels);

%% Transformar nodes IJK to RAS
ijk2lps = img.ijkToLpsTransform; % 4 x 4
mrVhomo = [mrV ones(length(mrV), 1)]'; % 4 x n
mrVlpsHomo = ijk2lps * mrVhomo; % 4 x n
mrVlps = mrVlpsHomo(1:3, :)'; % n x 3
mrVras = mrVlps;
mrVras(:, 1:2) = - mrVras(:, 1:2);


%% Output
mrF = mrF(:,1:3); % si no, quiza error en write_ply()


