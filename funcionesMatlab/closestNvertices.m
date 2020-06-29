function [closestVerticesIdx, closestVerticesCoordinates, distances] = closestNvertices(vertices, point, numCloseVertices)

    assert(numel(point) < 4, 'Only one point should be given.')
    
    if size(point, 1) > 1
        point = point';
    end
    
    diffs = vertices - repmat(point, [length(vertices) 1]);
    distancesToThisPoint = sqrt(sum(diffs.^2, 2));
    
    for i = 1 : numCloseVertices
        [distances(i), closestVerticesIdx(i)] = min(distancesToThisPoint);
        closestVerticesCoordinates(i,:) = vertices(closestVerticesIdx(i), :);
        distancesToThisPoint(closestVerticesIdx(i)) = Inf;
    end
    
    
    distances = distances';
    closestVerticesIdx = closestVerticesIdx';
    mat = [closestVerticesIdx distances closestVerticesCoordinates];
    mat = sortrows(mat);
    
    closestVerticesIdx = mat(:, 1);
    distances = mat(:,2);
    closestVerticesCoordinates = mat(:, 3:5);
    
end