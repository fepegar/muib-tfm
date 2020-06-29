function [v, f] = spheremesh(center, radius, resolution)

% A sphere with radius 5 and resolution 60 has around 4000 nodes.

if nargin == 3
    [x,y,z] = sphere(resolution);
else
    [x,y,z] = sphere;
end
p = surf2patch(x,y,z,'triangles');
p.vertices = radius * p.vertices + repmat(center, length(p.vertices), 1);
v = p.vertices;
f = p.faces;
