clc, clear, close all

ctPath = '/Users/fernando/Dropbox/MUIB/TFM/matlab/ctClipped_8.ply';
mrPath = '/Users/fernando/Dropbox/MUIB/TFM/matlab/mrClipped_40.ply';

ctCSVPath = '/Users/fernando/Dropbox/MUIB/TFM/escenasSlicer/0609_11Fiduciales/ct_11.fcsv';
mrCSVPath = '/Users/fernando/Dropbox/MUIB/TFM/escenasSlicer/0609_11Fiduciales/mr_11.fcsv';


[ctV, ctF] = read_mesh(ctPath);
% [ctV, ctF] = meshcheckrepair(ctV, ctF);
% m = makeMesh(ctV, ctF);
% vidx = m.vidx;
% ctB = vidx(logical(m.isboundaryv), :);

[mrV, mrF] = read_mesh(mrPath);
% [mrV, mrF] = meshcheckrepair(mrV, mrF);
m = makeMesh(mrV, mrF);
vidx = m.vidx;
mrB = vidx(logical(m.isboundaryv), :);




%%

ctLandmarks = fcsvread(ctCSVPath);
mrLandmarks = fcsvread(mrCSVPath);

mrVerticesIdx = closestvertices(mrV, mrLandmarks);
[~, closestVerticesCT] = closestvertices(ctV, ctLandmarks);

% Inicialización por centro de masas
ctCentroid = mean(ctV);
mrCentroid = mean(mrV);
mr2ct = ctCentroid - mrCentroid;

% % Inicialización por landmark central
% mr2ct = ctLandmarks(6,:) - mrLandmarks(6,:);

mrVRefCT = mrV + repmat(mr2ct, length(mrV), 1);


clear options
options.symmetrize = 0;
options.normalize = 1;
type = 'conformal';
L = compute_mesh_laplacian(mrVRefCT, mrF, type, options);


finalVertices = closestVerticesCT;%([4 6 11], :);
deformedIdx = mrVerticesIdx;%([4 6 11]);


[mrVDeformedBoundary] = MeshLaplacianDeform(L, ...
                                   mrVRefCT, ...
                                   finalVertices, ...
                                   deformedIdx, ...
                                   mrB);

[mrVDeformedFree] = MeshLaplacianDeform(L, ...
                                   mrVRefCT, ...
                                   finalVertices, ...
                                   deformedIdx, ...
                                   []);


distancesDeformationB = sqrt(sum((mrVDeformedBoundary-mrVRefCT).^2, 2));
distancesDeformationB = round(distancesDeformationB / max(distancesDeformationB) * 255);
my_write_ply(mrVDeformedBoundary,mrF,'/Users/fernando/Dropbox/MUIB/TFM/matlab/mrDeformedB_3.ply', distancesDeformationB)

distancesDeformationF = sqrt(sum((mrVDeformedFree-mrVRefCT).^2, 2));
distancesDeformationF = round(distancesDeformationF / max(distancesDeformationF) * 255);
my_write_ply(mrVDeformedFree,mrF,'/Users/fernando/Dropbox/MUIB/TFM/matlab/mrDeformedF_3.ply', distancesDeformationF)


deformationGIF(mrVRefCT, mrVDeformedFree, mrF, 4, 20, ['deformation_' type '.gif'],false)
deformationGIF(mrVRefCT, mrVDeformedFree, mrF, 4, 20, ['deformation_' type 'Rotating.gif'],true)

% %%
% 
% close all
% 
% clear opt
% opt.method='nonrigid_lowrank';
% opt.fgt = 2;
% opt.viz = 0;
% 
% % opt.tol = 1e-6;
% % opt.max_it = 50;
% 
% Transform = cpd_register(ctV, mrVDeformedBoundary, opt);
% mrVRegisteredBoundary = Transform.Y;
% distancesRegistrationB = sqrt(sum((mrVRegisteredBoundary-mrVRefCT).^2, 2));
% distancesRegistrationB = round(distancesRegistrationB / max(distancesRegistrationB) * 255);
% my_write_ply(mrVRegisteredBoundary, mrF, '/Users/fernando/Dropbox/MUIB/TFM/matlab/mrRegisteredB.ply', distancesRegistrationB);
% 
% Transform = cpd_register(ctV, mrVDeformedFree, opt);
% mrVRegisteredFree = Transform.Y;
% distancesRegistrationF = sqrt(sum((mrVRegisteredFree-mrVRefCT).^2, 2));
% distancesRegistrationF = round(distancesRegistrationF / max(distancesRegistrationF) * 255);
% my_write_ply(mrVRegisteredFree, mrF, '/Users/fernando/Dropbox/MUIB/TFM/matlab/mrRegisteredF.ply', distancesRegistrationF);


%% Visualización

az = -25;
el = 35;                       
% close all
figure

xlims = [-600 -100];
ylims = [-600 -200];
zlims = [0 220];

rows = 2;
columns = 3;
n = 1;


subplot(rows, columns, n), n = n+columns;
plot_mesh(mrVRefCT, mrF);
view(az,el), camlight, axis on, grid minor
hold on
scatter3(mrVRefCT(mrVerticesIdx,1), ...
    mrVRefCT(mrVerticesIdx,2), ...
    mrVRefCT(mrVerticesIdx,3), ...
    100, ...
    'filled')
scatter3(closestVerticesCT(:,1), ...
    closestVerticesCT(:,2), ...
    closestVerticesCT(:,3), ...
    100, ...
    'filled')
xlim(xlims)
ylim(ylims)
zlim(zlims)
e = mean(sqrt(sum((finalVertices - mrVRefCT(deformedIdx,:)).^2, 2)));
title(sprintf('MRI. MSE: %f', e))


subplot(rows, columns, n), n = n-columns+1;
plot_mesh(ctV, ctF);
view(az,el), camlight, axis on, grid minor
hold on
scatter3(closestVerticesCT(:,1), ...
    closestVerticesCT(:,2), ...
    closestVerticesCT(:,3), ...
    100, ...
    'r', ...
    'filled')
xlim(xlims)
ylim(ylims)
zlim(zlims)
e = 0;
title(sprintf('CT. MSE: %f', e))


subplot(rows, columns, n), n = n+columns;
clear opt
opt.face_vertex_color = distancesDeformationB;
plot_mesh(mrVDeformedBoundary, mrF, opt); colorbar
view(az,el), camlight, axis on, grid minor
hold on
scatter3(mrVDeformedBoundary(deformedIdx,1), ...
    mrVDeformedBoundary(deformedIdx,2), ...
    mrVDeformedBoundary(deformedIdx,3), ...
    100, ...
    'filled')
scatter3(finalVertices(:,1), ...
    finalVertices(:,2)+10, ...
    finalVertices(:,3), ...
    100, ...
    'filled')
xlim(xlims)
ylim(ylims)
zlim(zlims)
e = mean(sqrt(sum((finalVertices - mrVDeformedBoundary(deformedIdx,:)).^2, 2)));
title(sprintf('Deformed MRI (3 landmarks, fixed boundary). MSE: %f', e))



subplot(rows, columns, n), n = n-columns+1;
clear opt
opt.face_vertex_color = distancesDeformationB;
plot_mesh(mrVDeformedFree, mrF, opt); colorbar
view(az,el), camlight, axis on, grid minor
hold on
scatter3(mrVDeformedFree(deformedIdx,1), ...
    mrVDeformedFree(deformedIdx,2), ...
    mrVDeformedFree(deformedIdx,3), ...
    100, ...
    'filled')
scatter3(finalVertices(:,1), ...
    finalVertices(:,2)+10, ...
    finalVertices(:,3), ...
    100, ...
    'filled')
xlim(xlims)
ylim(ylims)
zlim(zlims)
e = mean(sqrt(sum((finalVertices - mrVDeformedFree(deformedIdx,:)).^2, 2)));
title(e)
title(sprintf('Deformed MRI (3 landmarks). MSE: %f', e))




finalVertices = closestVerticesCT;
deformedIdx = mrVerticesIdx;


[mrVDeformedBoundary] = MeshLaplacianDeform(L, ...
                                   mrVRefCT, ...
                                   finalVertices, ...
                                   deformedIdx, ...
                                   mrB);

[mrVDeformedFree] = MeshLaplacianDeform(L, ...
                                   mrVRefCT, ...
                                   finalVertices, ...
                                   deformedIdx, ...
                                   []);


distancesDeformationB = sqrt(sum((mrVDeformedBoundary-mrVRefCT).^2, 2));
distancesDeformationB = round(distancesDeformationB / max(distancesDeformationB) * 255);
my_write_ply(mrVDeformedBoundary,mrF,'/Users/fernando/Dropbox/MUIB/TFM/matlab/mrDeformedB_11.ply', distancesDeformationB)

distancesDeformationF = sqrt(sum((mrVDeformedFree-mrVRefCT).^2, 2));
distancesDeformationF = round(distancesDeformationF / max(distancesDeformationF) * 255);
my_write_ply(mrVDeformedFree,mrF,'/Users/fernando/Dropbox/MUIB/TFM/matlab/mrDeformedF_11.ply', distancesDeformationF)

subplot(rows, columns, n), n = n+columns;
clear opt
opt.face_vertex_color = distancesDeformationB;
plot_mesh(mrVDeformedBoundary, mrF, opt); colorbar
view(az,el), camlight, axis on, grid minor
hold on
scatter3(mrVDeformedBoundary(deformedIdx,1), ...
    mrVDeformedBoundary(deformedIdx,2), ...
    mrVDeformedBoundary(deformedIdx,3), ...
    100, ...
    'filled')
scatter3(finalVertices(:,1), ...
    finalVertices(:,2)+10, ...
    finalVertices(:,3), ...
    100, ...
    'filled')
xlim(xlims)
ylim(ylims)
zlim(zlims)
e = mean(sqrt(sum((finalVertices - mrVDeformedBoundary(deformedIdx,:)).^2, 2)));
title(sprintf('Deformed MRI (11 landmarks, fixed boundary). MSE: %f', e))



subplot(rows, columns, n), n = n-columns+1;
clear opt
opt.face_vertex_color = distancesDeformationB;
plot_mesh(mrVDeformedFree, mrF, opt); colorbar
view(az,el), camlight, axis on, grid minor
hold on
scatter3(mrVDeformedFree(deformedIdx,1), ...
    mrVDeformedFree(deformedIdx,2), ...
    mrVDeformedFree(deformedIdx,3), ...
    100, ...
    'filled')
scatter3(finalVertices(:,1), ...
    finalVertices(:,2)+10, ...
    finalVertices(:,3), ...
    100, ...
    'filled')
xlim(xlims)
ylim(ylims)
zlim(zlims)
e = mean(sqrt(sum((finalVertices - mrVDeformedFree(deformedIdx,:)).^2, 2)));
title(sprintf('Deformed MRI (11 landmarks). MSE: %f', e))





% subplot(rows, columns, n), n = n+1;
% opt.face_vertex_color = distancesRegistrationB;
% plot_mesh(mrVRegisteredBoundary, mrF, opt); colorbar
% view(az,el), camlight, axis on, grid minor
% hold on
% scatter3(mrVRegisteredBoundary(deformedIdx,1), ...
%     mrVRegisteredBoundary(deformedIdx,2), ...
%     mrVRegisteredBoundary(deformedIdx,3), ...
%     100, ...
%     'filled')
% scatter3(finalVertices(:,1), ...
%     finalVertices(:,2), ...
%     finalVertices(:,3), ...
%     100, ...
%     'filled')
% xlim(xlims)
% ylim(ylims)
% zlim(zlims)
% e = mean(sqrt(sum((finalVertices - mrVRegisteredBoundary(deformedIdx,:)).^2, 2)));
% title(e)
% 
% 
% subplot(rows, columns, n), n = n+1;
% opt.face_vertex_color = distancesRegistrationF;
% plot_mesh(mrVRegisteredFree, mrF, opt); colorbar
% view(az,el), camlight, axis on, grid minor
% hold on
% scatter3(mrVRegisteredFree(deformedIdx,1), ...
%     mrVRegisteredFree(deformedIdx,2), ...
%     mrVRegisteredFree(deformedIdx,3), ...
%     100, ...
%     'filled')
% scatter3(finalVertices(:,1), ...
%     finalVertices(:,2), ...
%     finalVertices(:,3), ...
%     100, ...
%     'filled')
% xlim(xlims)
% ylim(ylims)
% zlim(zlims)
% e = mean(sqrt(sum((finalVertices - mrVRegisteredFree(deformedIdx,:)).^2, 2)));
% title(e)


rotate3d
maximize
colormap parula




