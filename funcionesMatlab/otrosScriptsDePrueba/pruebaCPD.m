
clear, close all

[CT, facesCT] = read_mesh('ct.ply');
[MR, facesMR] = read_mesh('mr.ply');

figure
cpd_plot_iter(MR, CT)
title('Before')

clear opt

opt.method='nonrigid';%_lowrank';
opt.fgt = 2;
opt.viz = 1;
% opt.tol = 1e-7;
% opt.max_it = 50;

[Transform, C] = cpd_register(CT, MR, opt);

write_ply(Transform.Y, facesMR, 'regMeshMr2Ct_nonrigidlowrank_fgt2.ply');

cpd_plot_iter(Transform.Y, CT)

%%
pD = [-108 -160 182];
pI = [-270 -164 169];

close
plotmesh(MR, facesMR)
maximize
hold on

[nD, iD] = findclosest(MR, pD);
[nI, iI] = findclosest(MR, pI);
scatter3(nD(1), nD(2), nD(3), 100, 'r', 'filled')
scatter3(nI(1), nI(2), nI(3), 100, 'r', 'filled')

%% 

figure
plotmesh(Transform.Y, facesMR)
maximize
hold on

pDt = Transform.Y(iD,:);
pIt = Transform.Y(iI,:);
scatter3(pDt(1), pDt(2), pDt(3), 100, 'r', 'filled')
scatter3(pIt(1), pIt(2), pIt(3), 100, 'r', 'filled')

