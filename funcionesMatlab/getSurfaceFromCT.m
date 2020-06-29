function [nodesCTroiRAS, facesCTroi] = getSurfaceFromCT(img, roiRAS, simplify, n)

ct = imnorm(img.pixelData);

%% ROI calculation
roiVoxels = roiRAS2roiIJK(roiRAS, img);
dimImg = size(ct);
for dimension = 1:3
    ranges{dimension} = max(roiVoxels(1,dimension) - 10, 1) : min(roiVoxels(2,dimension) + 10, dimImg(dimension));
end

% %% Crop
% aux = zeros(size(ct));
% aux(ranges{1}, ranges{2}, ranges{3}) = ct(ranges{1}, ranges{2}, ranges{3});
% ct = aux;


%% Thresholding
thresh = multithresh(ct(:,:,round(size(ct,3)/2)), 2);
ctThresh = ct > thresh(2);


%% Fill holes
N = zeros(3,3,3); N(5) = 1; N(11:2:17) = 1; N(14) = 1; N(23) = 1;
ctOpened = imopen(ctThresh, ones(3,3,3));
ctLargest = largestregion(ctOpened);
ctMask = myfillholes3d(ctLargest);

%% Surface generation

% [nodesCT, facesCT,~,~] = vol2surf(... 
%     ctMask, ...
%     ranges{1}, ...
%     ranges{2}, ...
%     ranges{3}, ...
%     1 / simplifyingFactor, ...
%     1, ...
%     'simplify');

if nargin > 2
    [nodesCT, facesCT] = myvol2surf(ctMask,ranges,simplify, n);
else
    [nodesCT, facesCT] = myvol2surf(ctMask,ranges);
end


%% Eliminar pared CT
[nodesCTroi, facesCTroi] = cropMesh(nodesCT, facesCT, roiVoxels);


%% Transformar nodes IJK to RAS
ijk2lps = img.ijkToLpsTransform; % 4 x 4
nodesCTroiHomo = [nodesCTroi ones(length(nodesCTroi), 1)]'; % 4 x n
nodesCTroiLPSHomo = ijk2lps * nodesCTroiHomo; % 4 x n
nodesCTroiLPS = nodesCTroiLPSHomo(1:3, :)'; % n x 3
nodesCTroiRAS = nodesCTroiLPS;
nodesCTroiRAS(:, 1:2) = - nodesCTroiRAS(:, 1:2);


%% Output
facesCTroi = facesCTroi(:,1:3); % si no, quiza error en write_ply()







