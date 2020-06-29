function colors = ringsColors(vertices, geodesicDistancesRight, geodesicDistancesLeft, distanceBetweenPoints, ringsThickness, maxDistance, margin)

% Check vertices dimension
vertices = checkMeshDimension(vertices, 2); % Nx3

% Initialize variables
colors = ones(length(vertices),1);
radii = [];

if nargin < 7
    margin = 10; % Stop 1 cm before border
end

i = 1;
while((i * distanceBetweenPoints + ringsThickness/2) < (maxDistance - margin))
    radii = [radii; i * distanceBetweenPoints];
    i = i + 1;
end


for j = 1:length(radii)
    radius = radii(j);
    mask = (radius - ringsThickness/2 < geodesicDistancesRight) & (geodesicDistancesRight < radius + ringsThickness/2);
    colors(mask) = j+1;
end

for j = 1:length(radii)
    radius = radii(j);
    mask = (radius - ringsThickness/2 < geodesicDistancesLeft) & (geodesicDistancesLeft < radius + ringsThickness/2);
    colors(mask) = j+1;
end