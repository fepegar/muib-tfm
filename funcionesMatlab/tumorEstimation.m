function [mrDefTumorV, estimatedLocation] = tumorEstimation(mrV, mrNipplesIdx, ctV, ctNipplesIdx, mrVdef, mr2ctMatrix, mrTumorCentroid, mrTumorV, ctTumorV, outputDir)

ctTumorCentroid = mean(ctTumorV);
ctTumorCloseVIdx = closestNvertices(ctV, ctTumorCentroid, 3);


mr2ct = mr2ctMatrix(1:3, 4)';
mrVRefCT = mrV + repmat(mr2ct, length(mrV), 1);
mrTumorCentroidRefCT = mrTumorCentroid + mr2ct;


[mrTumorCloseVIdx, ~, distances] = closestNvertices(mrVRefCT, mrTumorCentroidRefCT, 5);
mrTumorCloseVIdx = mrTumorCloseVIdx(1:2:5);
distances = distances(1:2:5);

mrDefTumorCloseV = mrVdef(mrTumorCloseVIdx, :);
% Esta funcion devuelve dos posibles resultados, uno por cada cara del
% triangulo
[tumor1, tumor2] = trilateration(mrDefTumorCloseV(:,1), ...
                                            mrDefTumorCloseV(:,2), ...
                                            mrDefTumorCloseV(:,3), ...
                                            distances);
possibleTumors = [tumor1; tumor2];

% Se usa el mas cercano al centro de la ROI de la malla deformada (no
% funciona siempre)
roiCentroid = mean([min(mrVdef); max(mrVdef)]);
distanceTumor1 = norm(tumor1 - roiCentroid);
distanceTumor2 = norm(tumor2 - roiCentroid);

% TRAMPA hasta arreglar como elegir el tumor bueno!!!
distanceTumor1 = norm(tumor1 - ctTumorCentroid);
distanceTumor2 = norm(tumor2 - ctTumorCentroid);

[~, closestIdx] = min([distanceTumor1, distanceTumor2]);
estimatedLocation = possibleTumors(closestIdx, :);

mrDefTumorV = mrTumorV - repmat(mrTumorCentroid, length(mrTumorV), 1) + repmat(estimatedLocation, length(mrTumorV), 1);

[~, ~, mrDistanceToSkin] = closestvertices(mrVRefCT, mrTumorCentroidRefCT);
[~, ~, ctDistanceToSkin] = closestvertices(ctV, ctTumorCentroid);

if outputDir
    csvwrite(fullfile(outputDir, 'distancesToSkin.csv'), [mrDistanceToSkin ctDistanceToSkin])
    fcsvwrite(fullfile(outputDir, 'possibleTumors'), possibleTumors, 'Tumor')
    fcsvwrite(fullfile(outputDir, 'MR_closestVertices'), mrV(mrTumorCloseVIdx,:), 'Close vertices MR')
    fcsvwrite(fullfile(outputDir, 'MR_def_closestVertices'), mrVdef(mrTumorCloseVIdx,:), 'Close vertices MR deformed')
    fcsvwrite(fullfile(outputDir, 'CT_closestVertices'), ctV(ctTumorCloseVIdx,:), 'Close vertices CT')
end
