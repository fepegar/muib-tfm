
clc
% clear
close all

ctPath = '/Users/fernando/Dropbox/MUIB/TFM/matlab/ct.ply'; %Clipped_8.ply';
mrPath = '/Users/fernando/Dropbox/MUIB/TFM/matlab/mr.ply';%Clipped_40.ply';
mrDefPath = '/Users/fernando/Dropbox/MUIB/TFM/matlab/mrDeformedF_3.ply';
ctCSVPath = '/Users/fernando/Dropbox/MUIB/TFM/escenasSlicer/0609_11Fiduciales/ct_12.fcsv';
mrCSVPath = '/Users/fernando/Dropbox/MUIB/TFM/escenasSlicer/0609_11Fiduciales/mr_12.fcsv';

[ctV, ctF] = read_mesh(ctPath);
[ctV, ctF] = meshcheckrepair(ctV,ctF);

[mrV, mrF] = read_mesh(mrPath);
% [mrV, mrF]=meshcheckrepair(mrV,mrF);

mrVdef = read_mesh(mrDefPath);


ctLandmarks = fcsvread(ctCSVPath);
mrLandmarks = fcsvread(mrCSVPath);

ctTumor = ctLandmarks(end, :);
mrTumor = mrLandmarks(end, :);


ctCentroid = mean(ctV);
mrCentroid = mean(mrV);
mr2ct = ctCentroid - mrCentroid;
mrVRefCT = mrV + repmat(mr2ct, length(mrV), 1);
mrTumorRefCT = mrTumor + mr2ct;

%%


[mrTumorIdx, mrTumorV, distances] = closestNvertices(mrVRefCT, mrTumorRefCT, 3)


%%
close all
figure
plotmesh(mrVRefCT, mrF);
hold on
scatter3(mrTumorV(:,1), ...
    mrTumorV(:,2), ...
    mrTumorV(:,3), ...
    100, ...
    'y', ...
    'filled')
scatter3(mrTumorRefCT(:,1), ...
         mrTumorRefCT(:,2), ...
         mrTumorRefCT(:,3), ...
         400, ...
         'r', ...
         'filled')

%%

mrDefTumorV = mrVdef(mrTumorIdx, :);

[tumor1, tumor2, errorflag] = trilateration(mrDefTumorV(:,1), ...
                                            mrDefTumorV(:,2), ...
                                            mrDefTumorV(:,3), ...
                                            distances);
possibleTumors = [tumor1; tumor2];

                                        
figure
plotmesh(mrVdef, mrF);
hold on
scatter3(mrDefTumorV(:,1), ...
    mrDefTumorV(:,2), ...
    mrDefTumorV(:,3), ...
    100, ...
    'y', ...
    'filled')

scatter3(possibleTumors(:,1), ...
         possibleTumors(:,2), ...
         possibleTumors(:,3), ...
         400, ...
         'r', ...
         'filled')
scatter3(ctTumor(:,1), ...
         ctTumor(:,2), ...
         ctTumor(:,3), ...
         400, ...
         'g', ...
         'filled')

distFig









