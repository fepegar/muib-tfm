function [closestNode, index] = findclosest(mesh, p)

numPoints = length(mesh);

d = zeros(numPoints, 1);
for i = 1:numPoints
    d(i) = norm(mesh(i, :) - p);
end

[~, index] = min(d);

closestNode = mesh(index, :);