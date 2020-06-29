% [stmfile, stmpath] = uigetfile('*.vtk', 'pick text file');

clc, clear, close all

% CT = '/Users/fernando/Dropbox/MUIB/TFM/RIO42_2/PRE_CT_220909/maskCTcortada.ply';
CT = 'moreDecimated.ply';
MR = '/Users/fernando/Dropbox/MUIB/TFM/RIO42_2/PRE_RM_210809/mri_38791.ply';

[CT, facesCT] = read_mesh(CT);
[MR, facesMR] = read_mesh(MR); % moving

%% Resample

% No me vale para la reconstrucción
% puntos = 1000;
% CTr = CT(1: uint32(length(CT)/puntos) : end, :);
% MRr = MR(1: uint32(length(MR)/puntos) : end, :);

% % Con iso2mesh
% % El PC de labo no hace el de MR
% % Mac: permission denied
% [CTr, facesCTr] = meshresample(CT, facesCT, .05);
% [MRr, facesMRr] = meshresample(MR, facesMR, .05);

% Con toolbox_graph
% No funciona: QSlim: command not found
% [CTr, facesCTr] = perform_mesh_simplification(CT,facesCT,floor(length(facesCT))/5);

%% Registro CPD

% Cambiada línea 23 de cpd_make

close all
figure, cpd_plot_iter(MR, CT); title('Before');

clear opt

opt.method='nonrigid_lowrank';
opt.fgt = 2;
opt.viz = 1;
opt.tol = 1e-6;
% opt.max_it = 50;

[Transform, C] = cpd_register(MR, CT, opt);
write_ply(Transform.Y, facesCT, 'regMeshCt2Mri_nonrigidlowrank_fgt2_tol1e-6.ply');


%% 
































