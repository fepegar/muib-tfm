function [fiducials, scalars] = fiducialsGeodesicRadiiLines(vertices, faces, startPointsIdx, radii, thickness)

% vertices -> Nx3 or 3xN
% faces -> Nx3 or 3xN
% radii in mm
% thickness of rings around radii


if size(vertices,2)~=3
        vertices = vertices';
end
if size(vertices,2)~=3
    error('Vertices do not have correct format.');
end
% vertices is now Nx3 for sure

if size(faces,2)~=3
        faces = faces';
end
if size(faces,2)~=3
    error('Faces do not have correct format.');
end
% faces is now Nx3 for sure

boundaryV = compute_boundary(faces); % TODO: stop when fiducial in boundary
scalars = zeros(length(vertices),1);
fiducials = [];
% fiducials = zeros(length(startPointsIdx) * length(radii) * 4, 3);

for i = 1:size(startPointsIdx,1)
    vIdx = startPointsIdx(i);
    point = vertices(vIdx, :);
    
    D = perform_fast_marching_mesh(vertices', faces', vIdx);
    
    for j = 1:length(radii)
        radius = radii(j);
        mask = (radius - thickness/2 < D) & (D < radius + thickness/2);
        verticesRing = vertices(mask, :);
        
        % Colors different to background, but increasing luminosity with
        % distance
        scalars(mask) = 5+j;
        
        % Supposing RAS
        
        % R: remove vertices to the left, compare Z
        auxRing = verticesRing;
        auxRing(auxRing(:,1) < point(1), :) = []; % Inf would work too
        [~,idx] = min(abs(auxRing(:,3) - point(3)));
        fiducials = [fiducials; auxRing(idx,:)];
        
        % L: remove vertices to the Right, compare Z
        auxRing = verticesRing;
        auxRing(auxRing(:,1) > point(1), :) = []; 
        [~,idx] = min(abs(auxRing(:,3) - point(3)));
        fiducials = [fiducials; auxRing(idx,:)];
        
        % S: remove vertices to Inferior, compare X
        auxRing = verticesRing;
        auxRing(auxRing(:,3) < point(3), :) = []; 
        [~,idx] = min(abs(auxRing(:,1) - point(1)));
        fiducials = [fiducials; auxRing(idx,:)];
        
        % I: remove vertices to Superior, compare X
        auxRing = verticesRing;
        auxRing(auxRing(:,3) > point(3), :) = []; 
        [~,idx] = min(abs(auxRing(:,1) - point(1)));
        fiducials = [fiducials; auxRing(idx,:)];
    end
    
end
