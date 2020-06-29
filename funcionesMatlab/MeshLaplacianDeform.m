function [ verticesnew ] = MeshLaplacianDeform(L, vertices, apex, IdApex, IdEdge)

% L        - Laplacian matrix
% vertices - Points of the mesh
% apex     - New spatial coordinates (x,y,z) of vertices(IdApex,:)
% IdApex   - vertex number deformed to new coordinates defined by apex
% IdEdge   - vvertices that are not deformed

%http://doc.cgal.org/latest/Surface_modeling/index.html#mjx-eqn-eqlap_system
% Equation (3)

if size(IdApex,2) == 1
    IdApex=IdApex';
end
if size(IdEdge,2) == 1
    IdEdge=IdEdge';
end

DeltaF    = L*vertices;

%IdEdge    = [IdEdge;IdEdge2];
nVertices = size(vertices,1);
nAtractors = numel(IdApex);
for i=1:numel(IdEdge)
    L(IdEdge(i),:) = zeros(1,nVertices);
    L(IdEdge(i),IdEdge(i)) = 1;
end
nL = zeros(nAtractors,nVertices);
for i=1:nAtractors
    nL(i,IdApex(i))=1;
end
L = [L; nL];

verticesO = vertices;
DeltaF(IdEdge,:) = verticesO(IdEdge,:);
Ndelta = apex;
DeltaF = [DeltaF;Ndelta];


VnewX = L\DeltaF(:,1);
VnewY = L\DeltaF(:,2);
VnewZ = L\DeltaF(:,3);

verticesnew  = [VnewX,VnewY,VnewZ];


end

