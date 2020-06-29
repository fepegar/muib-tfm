function [meanDistance, distances] = distancesBetweenNodes(vertices, faces)

edges = compute_edges(faces)';
numEdges = length(edges);
distances = zeros(1, numEdges);

for i = 1:numEdges
    nodes = edges(i,:);
    distances(i) = norm(vertices(nodes(1),:) - vertices(nodes(2),:));
end

meanDistance = mean(distances);