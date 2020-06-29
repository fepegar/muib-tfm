function [closestVerticesIdx, closestVerticesCoordinates, distances] = closestvertices(vertices, points)
    
    vertices = checkMeshDimension(vertices, 2);
    
    numVertices = size(vertices, 1);
    numPoints = size(points, 1);

    for i = 1:numPoints
        diffs = vertices - repmat(points(i, :), [numVertices 1]);
        distancesToThisPoint = sqrt(sum(diffs.^2, 2));

        [distances(i), closestVerticesIdx(i)] = min(distancesToThisPoint);
        closestVerticesCoordinates(i,:) = vertices(closestVerticesIdx(i), :);
    end
    
    closestVerticesIdx = closestVerticesIdx';
    distances = distances';
end