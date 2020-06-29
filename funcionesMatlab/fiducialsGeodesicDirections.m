function fiducials = fiducialsGeodesicDirections(vertices, startingPointIdx, geodesicDistances, maxDistance, ringsThickness, distanceBetweenPoints, direction, distances, margin)

vertices = checkMeshDimension(vertices, 2); % Nx3


fiducials = [];

if nargin < 9
    margin = 10; % Stop 10 mm before border
end

radiiLinear = [];
i = 1;
while((i * distanceBetweenPoints + ringsThickness/2) < (maxDistance - margin))
    radiiLinear = [radiiLinear; i * distanceBetweenPoints];
    i = i + 1;
end

% Distances between points are always the same only if direction is medial
switch distances
    case 'linear'
        radii = radiiLinear;
    case 'compressed'
        distFin = maxDistance - margin;
        separationIni = distanceBetweenPoints;
        separationFin = 2; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % s = m*x + n;
        m = (separationFin - separationIni) / distFin;
        
        radii(1) = 0;
        for i = 1:length(radiiLinear)-1
            separation = m * radii(i) + separationIni;
            radii(i+1) = radii(i) + separation;
        end
end




startingPoint = vertices(startingPointIdx, :);

for i = 1:length(radii)
    radius = radii(i);
    mask = (radius - ringsThickness/2 < geodesicDistances) & (geodesicDistances < radius + ringsThickness/2);
    verticesRing = vertices(mask, :);
    
    aux = verticesRing;
    switch direction % Supposing RAS
        case 'right'
            aux(aux(:,1) < startingPoint(1), :) = []; % Remove vertices to the left
            [~, vertexIdx] = min(abs(aux(:,3) - startingPoint(3))); % Similar Z
        case 'left'
            aux(aux(:,1) > startingPoint(1), :) = []; % Remove vertices to the right
            [~, vertexIdx] = min(abs(aux(:,3) - startingPoint(3))); % Similar Z
        case 'cranial'
            aux(aux(:,3) < startingPoint(3), :) = []; % Remove more caudal vertices
            [~, vertexIdx] = min(abs(aux(:,1) - startingPoint(1))); % Similar X
        case 'caudal'
            aux(aux(:,3) > startingPoint(3), :) = []; % Remove more caudal vertices
            [~, vertexIdx] = min(abs(aux(:,1) - startingPoint(1))); % Similar X
    end
    fiducials = [fiducials; aux(vertexIdx, :)];
end

