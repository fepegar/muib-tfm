function [croppedNodes, croppedFaces] = cropMesh(nodes, faces, roiVoxels)

centroids = meshcentroid(nodes, faces(:,1:3));
x = centroids(:,1);
y = centroids(:,2);
z = centroids(:,3);

idx = find(x > roiVoxels(1));
idx = intersect(idx, find(x < roiVoxels(2)));
idx = intersect(idx, find(y > roiVoxels(3)));
idx = intersect(idx, find(y < roiVoxels(4)));
idx = intersect(idx, find(z > roiVoxels(5)));
idx = intersect(idx, find(z < roiVoxels(6)));

croppedFaces = faces(idx, :);
[croppedNodes, croppedFaces] = meshcheckrepair(nodes, croppedFaces);


% grLabel should be used to keep only the largest connected component.
% However it is too slow (95 s for a 40 kv mesh),
% so it might be better to preprocess the mesh before,
% removing the smaller connected components with a 3rd-party
% software.