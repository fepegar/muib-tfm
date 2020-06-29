
[D,S,Q] = perform_fast_marching_mesh(ctV', ctF', ctNipplesIdx);
a=zeros(length(D),1);

m = (38 < D) & (D < 42);
a(m) = 255;

n = ctV(m, :);

p = ctV(ctIdx,:);
p1 = p(1,:);

[mi,i] = min(abs(n(:,3) - p1(3)));

fid = n(i,:);

%%


[fid, scalars] = fiducialsGeodesic(vertices, faces, ctIdx, [20 30 40 60 100], 4);


close all
figure
clear options
options.start_points = ctIdx;
plot_fast_marching_mesh(ctV', ctF', scalars, [], options);
shading interp;
view(az,el), camlight
colormap parula

hold on
scatter3(fid(:,1),fid(:,2),fid(:,3),100,'filled','g')
scatter3(ctV(b,1),ctV(b,2),ctV(b,3),20,'filled','r')

maximize





%%

[mrV, mrF] = read_ply('/Users/fernando/Dropbox/MUIB/TFM/data/caso_3/mrml/Output surface MR.ply');
[ctV, ctF] = read_ply('/Users/fernando/Dropbox/MUIB/TFM/data/caso_3/mrml/Output surface CT.ply');
mrFiducials = fcsvread('/Users/fernando/Dropbox/MUIB/TFM/data/caso_3/mrml/caso3MRFiducials9.fcsv');
ctFiducials = fcsvread('/Users/fernando/Dropbox/MUIB/TFM/data/caso_3/mrml/caso3CTFiducials9.fcsv');

mrNipplesFiducials = mrFiducials([2 4], :);
mrNipplesIdx = closestvertices(mrV, mrNipplesFiducials);

ctNipplesFiducials = ctFiducials([2 4], :);
ctNipplesIdx = closestvertices(ctV, ctNipplesFiducials);

%%
fiducialsGeodesicLines(mrV, mrF, mrNipplesIdx, ctV, ctF, ctNipplesIdx)

[fid, scalars] = fiducialsGeodesicRadiiLines(ctV, ctF, ctNipplesIdx, 150, 10);


az = -25;
el = 35;   
close all
figure
clear options
options.start_points = ctNipplesIdx;
plot_fast_marching_mesh(ctV', ctF', scalars, [], options);
% plot_mesh(mrV,mrF);
shading flat
view(az,el), camlight
colormap parula

% hold on
% scatter3(fid(:,1),fid(:,2),fid(:,3),100,'filled','g')
% % scatter3(mrV(mrNipplesIdx,1),mrV(mrNipplesIdx,2),mrV(mrNipplesIdx,3),100,'filled','g')
% scatter3(mrNipplesFiducials(:,1),mrNipplesFiducials(:,2),mrNipplesFiducials(:,3),100,'filled','g')
maximize



%%

[mrFiducials, ctFiducials] = fiducialsGeodesicLines(mrV, mrF, mrNipplesIdx, ctV, ctF, ctNipplesIdx);
mrGeodesicDistances = perform_fast_marching_mesh(mrV', mrF', mrNipplesIdx);
ctGeodesicDistances = perform_fast_marching_mesh(ctV', ctF', ctNipplesIdx);

%%

az = 175;
el = 35;   
close all

figure
clear options
options.start_points = mrNipplesIdx;
plot_fast_marching_mesh(mrV', mrF', mrGeodesicDistances, [], options);
% plot_mesh(mrV,mrF);
shading interp
view(az,el), camlight
colormap parula
hold on
scatter3(mrFiducials(:,1),mrFiducials(:,2),mrFiducials(:,3),100,'filled','r')

figure
clear options
options.start_points = ctNipplesIdx;
plot_fast_marching_mesh(ctV', ctF', ctGeodesicDistances, [], options);
% plot_mesh(ctV,ctF);
shading interp
view(az,el), camlight
colormap parula
hold on
scatter3(ctFiducials(:,1),ctFiducials(:,2),ctFiducials(:,3),100,'filled','r')

distFig


%% 

[ctV,ctF]=read_ply('/Users/fernando/Dropbox/MUIB/TFM/data/caso_5/mrml/ct_smoothed_subsampled.ply');
ctBoundaryIdx = compute_boundary(ctF);


az = 175;
el = 35;   
close all

figure
plot_mesh(ctV,ctF);
shading interp
view(az,el), camlight
colormap parula
hold on
scatter3(ctV(ctBoundaryIdx,1),ctV(ctBoundaryIdx,2),ctV(ctBoundaryIdx,3),100,'filled','r')

%%

mrPath = '/Users/fernando/Dropbox/MUIB/TFM/data/caso_9/mrml/Output surface MR.ply';
[mrV, mrF] = read_ply(mrPath);
vertices = mrV;
mrNipplesFiducials = fcsvread('/Users/fernando/Dropbox/MUIB/TFM/data/caso_9/mrml/MR_nipples.fcsv');
mrNipplesIdx = closestvertices(mrV, mrNipplesFiducials);
distanceBetweenPoints = 15;
ringsThickness = 5;
maxDistance = 150;

geodesicDistancesRight = perform_fast_marching_mesh(mrV', mrF', mrNipplesIdx(1));
geodesicDistancesLeft  = perform_fast_marching_mesh(mrV', mrF', mrNipplesIdx(2));

colors = ringsColors(vertices, geodesicDistancesRight, geodesicDistancesLeft, distanceBetweenPoints, ringsThickness, maxDistance);

my_write_ply(mrV,mrF,mrPath,colors)

%%
az = 175;
el = 35;   
close all
figure
clear options
options.start_points = mrNipplesIdx;
plot_fast_marching_mesh(mrV', mrF', colors, [], options);
shading flat
view(az,el), camlight
colormap hsv

maximize

%%

mrPath = '/Users/fernando/Dropbox/MUIB/TFM/data/caso_4/mrml/Output surface MR.ply';
[mrV, mrF] = read_ply(mrPath);
vertices = mrV;
mrNipplesFiducials = fcsvread('/Users/fernando/Dropbox/MUIB/TFM/data/caso_9/mrml/MR_nipples.fcsv');
mrNipplesIdx = closestvertices(mrV, mrNipplesFiducials);

v = mrV;
f = mrF;

h = waitbar(0);
for i = 1:16
    [v,f] = meshresample(v,f,.95);
    tic;
    compute_boundary(f);
    times(i) = toc;
    numPoints(i) = length(v);
    numFaces(i) = length(f);
    waitbar(i / 100)
end
close(h)

scatter(times)


l=length(v);
for i = 1:1000
    l=l*.9;
    if l < 10000
        break
    end
end
i


%%

colors = zeros(length(mrV),1);
colors(mask) = 1;

az = 175;
el = 35;   
close all
figure
clear options
options.start_points = closestvertices(mrV,mrCentralPoint);
plot_fast_marching_mesh(mrV', mrF', colors, [], options);
shading flat
view(az,el), camlight
colormap parula

maximize





