function [mrFiducials, mrColors, ctFiducials, ctColors, mr2ctMatrix, mrPointBetweenNipples] = fiducialsGeodesicLines(mrV, mrF, mrNipplesIdx, ctV, ctF, ctNipplesIdx, distanceBetweenPoints, initialization, fiducialsDir)

% vertices -> Nx3 or 3xN
% faces -> Nx3 or 3xN

mrV = checkMeshDimension(mrV, 2);
mrF = checkMeshDimension(mrF, 2);
ctV = checkMeshDimension(ctV, 2);
ctF = checkMeshDimension(ctF, 2);
% all Nx3


mrNippleRightIdx = mrNipplesIdx(1);
mrNippleLeftIdx  = mrNipplesIdx(2);
mrNippleRight = mrV(mrNippleRightIdx, :);
mrNippleLeft = mrV(mrNippleLeftIdx, :);
mrGeodesicDistancesRight = perform_fast_marching_mesh(mrV', mrF', mrNippleRightIdx);
mrGeodesicDistancesLeft  = perform_fast_marching_mesh(mrV', mrF', mrNippleLeftIdx);
mrNipplesDistance = mrGeodesicDistancesRight(mrNippleLeftIdx);

ctNippleRightIdx = ctNipplesIdx(1);
ctNippleLeftIdx  = ctNipplesIdx(2);
ctNippleRight = ctV(ctNippleRightIdx, :);
ctNippleLeft = ctV(ctNippleLeftIdx, :);
ctGeodesicDistancesRight = perform_fast_marching_mesh(ctV', ctF', ctNippleRightIdx);
ctGeodesicDistancesLeft  = perform_fast_marching_mesh(ctV', ctF', ctNippleLeftIdx);
ctNipplesDistance = ctGeodesicDistancesRight(ctNippleLeftIdx);

maxDistanceMedial = min(mrNipplesDistance, ctNipplesDistance) / 2;

%% Warping initialization
% Central points (between nipples)

ringsThickness = 5;
mrCentralPointZ = mean([mrNippleRight(3), mrNippleLeft(3)]);
radius = mrNipplesDistance / 2;
mask = (radius - ringsThickness/2 < mrGeodesicDistancesRight) & (mrGeodesicDistancesRight < radius + ringsThickness/2);
verticesRing = mrV(mask, :);
aux = verticesRing;
aux(aux(:,1) > mrNippleRight(1), :) = []; % Remove vertices to the right
[~, vertexIdx] = min(abs(aux(:,3) - mrCentralPointZ)); % Similar Z
mrCentralPoint = aux(vertexIdx, :);
mrPointBetweenNipples = mrCentralPoint;

ctCentralPointZ = mean([ctNippleRight(3), ctNippleLeft(3)]);
radius = ctNipplesDistance / 2;
mask = (radius - ringsThickness/2 < ctGeodesicDistancesRight) & (ctGeodesicDistancesRight < radius + ringsThickness/2);
verticesRing = ctV(mask, :);
aux = verticesRing;
aux(aux(:,1) > ctNippleRight(1), :) = []; % Remove vertices to the right
[~, vertexIdx] = min(abs(aux(:,3) - ctCentralPointZ)); % Similar Z
ctCentralPoint = aux(vertexIdx, :);
    
if strcmp(initialization, 'centralPoints')

    mr2ct = ctCentralPoint - mrCentralPoint;

elseif strcmp(initialization, 'centroids')
    % Centroid initialization
    ctCentralPoint = mean(ctV);
    mrCentralPoint = mean(mrV);
    mr2ct = ctCentralPoint - mrCentralPoint;
end

if fiducialsDir
    fcsvwrite(fullfile(fiducialsDir, 'MR_initializationCenter'), mrCentralPoint, 'MR_center')
    fcsvwrite(fullfile(fiducialsDir, 'CT_initializationCenter'), ctCentralPoint, 'CT_center')
end
    
mr2ctMatrix = eye(4);
mr2ctMatrix(1:3, 4) = mr2ct';


%% Distances to boundaries calculation -supposing RAS orientation-

mrBoundaryIdx = compute_boundary(mrF);
ctBoundaryIdx = compute_boundary(ctF);
mrBoundaryV = mrV(mrBoundaryIdx, :);
ctBoundaryV = ctV(ctBoundaryIdx, :);


%% Right nipple

% Lateral
aux = mrBoundaryV;
aux(aux(:,1) < mrNippleRight(1), :) = []; % Remove more medial vertices
if isempty(aux)
    error('Error computing MR mesh boundaries')
end
[~, mrNippleRightLateralAuxIdx] = min(abs(aux(:,3) - mrNippleRight(3))); % Similar Z
mrNippleRightLateral = aux(mrNippleRightLateralAuxIdx, :);
mrNippleRightLateralIdx = closestvertices(mrV, mrNippleRightLateral);
mrNippleRightLateralDistance = mrGeodesicDistancesRight(mrNippleRightLateralIdx);

aux = ctBoundaryV;
aux(aux(:,1) < ctNippleRight(1), :) = []; % Remove more medial vertices
if isempty(aux)
    error('Error computing CT mesh boundaries')
end
[~, ctNippleRightLateralAuxIdx] = min(abs(aux(:,3) - ctNippleRight(3))); % Similar Z
ctNippleRightLateral = aux(ctNippleRightLateralAuxIdx, :);
ctNippleRightLateralIdx = closestvertices(ctV, ctNippleRightLateral);
ctNippleRightLateralDistance = ctGeodesicDistancesRight(ctNippleRightLateralIdx);
maxDistanceLateralRight = min(mrNippleRightLateralDistance, ctNippleRightLateralDistance);

% Cranial
aux = mrBoundaryV;
aux(aux(:,3) < mrNippleRight(3), :) = []; % Remove more caudal vertices
[~, mrNippleRightCranialAuxIdx] = min(abs(aux(:,1) - mrNippleRight(1))); % Similar X
mrNippleRightCranial = aux(mrNippleRightCranialAuxIdx, :);
mrNippleRightCranialIdx = closestvertices(mrV, mrNippleRightCranial);
mrNippleRightCranialDistance = mrGeodesicDistancesRight(mrNippleRightCranialIdx);

aux = ctBoundaryV;
aux(aux(:,3) < ctNippleRight(3), :) = []; % Remove more caudal vertices
[~, ctNippleRightCranialAuxIdx] = min(abs(aux(:,1) - ctNippleRight(1))); % Similar X
ctNippleRightCranial = aux(ctNippleRightCranialAuxIdx, :);
ctNippleRightCranialIdx = closestvertices(ctV, ctNippleRightCranial);
ctNippleRightCranialDistance = ctGeodesicDistancesRight(ctNippleRightCranialIdx);

maxDistanceCranialRight = min(mrNippleRightCranialDistance, ctNippleRightCranialDistance);


% Caudal
aux = mrBoundaryV;
aux(aux(:,3) > mrNippleRight(3), :) = []; % Remove more cranial vertices
[~, mrNippleRightCaudalAuxIdx] = min(abs(aux(:,1) - mrNippleRight(1))); % Similar X
mrNippleRightCaudal = aux(mrNippleRightCaudalAuxIdx, :);
mrNippleRightCaudalIdx = closestvertices(mrV, mrNippleRightCaudal);
mrNippleRightCaudalDistance = mrGeodesicDistancesRight(mrNippleRightCaudalIdx);

aux = ctBoundaryV;
aux(aux(:,3) > ctNippleRight(3), :) = []; % Remove more cranial vertices
[~, ctNippleRightCaudalAuxIdx] = min(abs(aux(:,1) - ctNippleRight(1))); % Similar X
ctNippleRightCaudal = aux(ctNippleRightCaudalAuxIdx, :);
ctNippleRightCaudalIdx = closestvertices(ctV, ctNippleRightCaudal);
ctNippleRightCaudalDistance = ctGeodesicDistancesRight(ctNippleRightCaudalIdx);

maxDistanceCaudalRight = min(mrNippleRightCaudalDistance, ctNippleRightCaudalDistance);



%% Left nipple

% Lateral
aux = mrBoundaryV;
aux(aux(:,1) > mrNippleLeft(1), :) = []; % Remove more medial vertices
[~, mrNippleLeftLateralAuxIdx] = min(abs(aux(:,3) - mrNippleLeft(3))); % Similar Z
mrNippleLeftLateral = aux(mrNippleLeftLateralAuxIdx, :);
mrNippleLeftLateralIdx = closestvertices(mrV, mrNippleLeftLateral);
mrNippleLeftLateralDistance = mrGeodesicDistancesLeft(mrNippleLeftLateralIdx);
aux = ctBoundaryV;
aux(aux(:,1) > ctNippleLeft(1), :) = []; % Remove more medial vertices
[~, ctNippleLeftLateralAuxIdx] = min(abs(aux(:,3) - ctNippleLeft(3))); % Similar Z
ctNippleLeftLateral = aux(ctNippleLeftLateralAuxIdx, :);
ctNippleLeftLateralIdx = closestvertices(ctV, ctNippleLeftLateral);
ctNippleLeftLateralDistance = ctGeodesicDistancesLeft(ctNippleLeftLateralIdx);

maxDistanceLateralLeft = min(mrNippleLeftLateralDistance, ctNippleLeftLateralDistance);


% Cranial
aux = mrBoundaryV;
aux(aux(:,3) < mrNippleLeft(3), :) = []; % Remove more caudal vertices
[~, mrNippleLeftCranialAuxIdx] = min(abs(aux(:,1) - mrNippleLeft(1))); % Similar X
mrNippleLeftCranial = aux(mrNippleLeftCranialAuxIdx, :);
mrNippleLeftCranialIdx = closestvertices(mrV, mrNippleLeftCranial);
mrNippleLeftCranialDistance = mrGeodesicDistancesLeft(mrNippleLeftCranialIdx);

aux = ctBoundaryV;
aux(aux(:,3) < ctNippleLeft(3), :) = []; % Remove more caudal vertices
[~, ctNippleLeftCranialAuxIdx] = min(abs(aux(:,1) - ctNippleLeft(1))); % Similar X
ctNippleLeftCranial = aux(ctNippleLeftCranialAuxIdx, :);
ctNippleLeftCranialIdx = closestvertices(ctV, ctNippleLeftCranial);
ctNippleLeftCranialDistance = ctGeodesicDistancesLeft(ctNippleLeftCranialIdx);

maxDistanceCranialLeft = min(mrNippleLeftCranialDistance, ctNippleLeftCranialDistance);


% Caudal
aux = mrBoundaryV;
aux(aux(:,3) > mrNippleLeft(3), :) = []; % Remove more cranial vertices
[~, mrNippleLeftCaudalAuxIdx] = min(abs(aux(:,1) - mrNippleLeft(1))); % Similar X
mrNippleLeftCaudal = aux(mrNippleLeftCaudalAuxIdx, :);
mrNippleLeftCaudalIdx = closestvertices(mrV, mrNippleLeftCaudal);
mrNippleLeftCaudalDistance = mrGeodesicDistancesLeft(mrNippleLeftCaudalIdx);

aux = ctBoundaryV;
aux(aux(:,3) > ctNippleLeft(3), :) = []; % Remove more cranial vertices
[~, ctNippleLeftCaudalAuxIdx] = min(abs(aux(:,1) - ctNippleLeft(1))); % Similar X
ctNippleLeftCaudal = aux(ctNippleLeftCaudalAuxIdx, :);
ctNippleLeftCaudalIdx = closestvertices(ctV, ctNippleLeftCaudal);
ctNippleLeftCaudalDistance = ctGeodesicDistancesLeft(ctNippleLeftCaudalIdx);

maxDistanceCaudalLeft = min(mrNippleLeftCaudalDistance, ctNippleLeftCaudalDistance);



%% Fiducials for deformation
mrFiducials = [mrNippleRight; mrNippleLeft];
ctFiducials = [ctNippleRight; ctNippleLeft];
if nargin < 7
    distanceBetweenPoints = 15; % mm
end
ringsThickness = 5; % mm %%%%%%%%%%%%
marginMedial = 0;

%% Right nipple fiducials

% Medial
mrFiducials = [mrFiducials; fiducialsGeodesicDirections(mrV, ...
    mrNippleRightIdx, mrGeodesicDistancesRight, maxDistanceMedial, ...
    ringsThickness, distanceBetweenPoints, 'left', 'linear', marginMedial)];
ctFiducials = [ctFiducials; fiducialsGeodesicDirections(ctV, ...
    ctNippleRightIdx, ctGeodesicDistancesRight, maxDistanceMedial, ...
    ringsThickness, distanceBetweenPoints, 'left', 'linear', marginMedial)];

% Lateral
mrFiducials = [mrFiducials; fiducialsGeodesicDirections(mrV, ...
    mrNippleRightIdx, mrGeodesicDistancesRight, maxDistanceLateralRight, ...
    ringsThickness, distanceBetweenPoints, 'right', 'linear')];
ctFiducials = [ctFiducials; fiducialsGeodesicDirections(ctV, ...
    ctNippleRightIdx, ctGeodesicDistancesRight, maxDistanceLateralRight, ...
    ringsThickness, distanceBetweenPoints, 'right', 'compressed')];

% Cranial
mrFiducials = [mrFiducials; fiducialsGeodesicDirections(mrV, ...
    mrNippleRightIdx, mrGeodesicDistancesRight, maxDistanceCranialRight, ...
    ringsThickness, distanceBetweenPoints, 'cranial', 'linear')];
ctFiducials = [ctFiducials; fiducialsGeodesicDirections(ctV, ...
    ctNippleRightIdx, ctGeodesicDistancesRight, maxDistanceCranialRight, ...
    ringsThickness, distanceBetweenPoints, 'cranial', 'linear')];

% Caudal
mrFiducials = [mrFiducials; fiducialsGeodesicDirections(mrV, ...
    mrNippleRightIdx, mrGeodesicDistancesRight, maxDistanceCaudalRight, ...
    ringsThickness, distanceBetweenPoints, 'caudal', 'linear')];
ctFiducials = [ctFiducials; fiducialsGeodesicDirections(ctV, ...
    ctNippleRightIdx, ctGeodesicDistancesRight, maxDistanceCaudalRight, ...
    ringsThickness, distanceBetweenPoints, 'caudal', 'linear')];


%% Left nipple fiducials

% Medial
mrFiducials = [mrFiducials; fiducialsGeodesicDirections(mrV, ...
    mrNippleLeftIdx, mrGeodesicDistancesLeft, maxDistanceMedial, ...
    ringsThickness, distanceBetweenPoints, 'right', 'linear', marginMedial)];
ctFiducials = [ctFiducials; fiducialsGeodesicDirections(ctV, ...
    ctNippleLeftIdx, ctGeodesicDistancesLeft, maxDistanceMedial, ...
    ringsThickness, distanceBetweenPoints, 'right', 'linear', marginMedial)];

% Lateral
mrFiducials = [mrFiducials; fiducialsGeodesicDirections(mrV, ...
    mrNippleLeftIdx, mrGeodesicDistancesLeft, maxDistanceLateralLeft, ...
    ringsThickness, distanceBetweenPoints, 'left', 'linear')];
ctFiducials = [ctFiducials; fiducialsGeodesicDirections(ctV, ...
    ctNippleLeftIdx, ctGeodesicDistancesLeft, maxDistanceLateralLeft, ...
    ringsThickness, distanceBetweenPoints, 'left', 'compressed')];

% Cranial
mrFiducials = [mrFiducials; fiducialsGeodesicDirections(mrV, ...
    mrNippleLeftIdx, mrGeodesicDistancesLeft, maxDistanceCranialLeft, ...
    ringsThickness, distanceBetweenPoints, 'cranial', 'linear')];
ctFiducials = [ctFiducials; fiducialsGeodesicDirections(ctV, ...
    ctNippleLeftIdx, ctGeodesicDistancesLeft, maxDistanceCranialLeft, ...
    ringsThickness, distanceBetweenPoints, 'cranial', 'linear')];

% Caudal
mrFiducials = [mrFiducials; fiducialsGeodesicDirections(mrV, ...
    mrNippleLeftIdx, mrGeodesicDistancesLeft, maxDistanceCaudalLeft, ...
    ringsThickness, distanceBetweenPoints, 'caudal', 'linear')];
ctFiducials = [ctFiducials; fiducialsGeodesicDirections(ctV, ...
    ctNippleLeftIdx, ctGeodesicDistancesLeft, maxDistanceCaudalLeft, ...
    ringsThickness, distanceBetweenPoints, 'caudal', 'linear')];


%% Colors
mrColors = ringsColors(mrV, mrGeodesicDistancesRight, mrGeodesicDistancesLeft, distanceBetweenPoints, ringsThickness, maxDistanceMedial, marginMedial);
ctColors = ringsColors(ctV, ctGeodesicDistancesRight, ctGeodesicDistancesLeft, distanceBetweenPoints, ringsThickness, maxDistanceMedial, marginMedial);
