
mesh = readMesh('plane.obj');
v = mesh.v;
n = v;
f = mesh.f;

b = mesh.isboundaryv;
b = find(b);

v(:, [2 3]) = v(:, [3 2]);

plotmesh(v,f)
grid minor
maximize
rotate3d



%%

idx1 = closestvertex(v, [0 -.15 0]);
idx2 = closestvertex(v, [0  .15 0]);


clear options
options.symmetrize = 0;
options.normalize = 1;
L = compute_mesh_laplacian(v, f, 'conformal', options);


verticesnew = MeshLaplacianDeform(L, v, [0 -.15 .3;0 .15 -.3], [idx1 idx2], b);

plotmesh(verticesnew,f)
grid minor
maximize
rotate3d






