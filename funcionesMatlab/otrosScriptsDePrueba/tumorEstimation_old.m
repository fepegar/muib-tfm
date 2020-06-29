function [mrDefTumorV, estimatedLocation] = tumorEstimation(mrV, mrNipplesIdx, ctV, ctNipplesIdx, mrVdef, mr2ctMatrix, mrTumorCentroid, mrTumorV, ctTumorV, outputDir)

% Tumor in right or left breast?
tumorToRightNipple = norm(mrTumorCentroid - mrV(mrNipplesIdx(1), :));
tumorToLeftNipple  = norm(mrTumorCentroid - mrV(mrNipplesIdx(2), :));
[~, laterality] = min([tumorToRightNipple; tumorToLeftNipple]);
closestNippleIdx = mrNipplesIdx(laterality);
% Laterality:
%  1: right
%  2: left


mr2ct = mr2ctMatrix(1:3, 4)';
mrVRefCT = mrV + repmat(mr2ct, length(mrV), 1);
mrTumorCentroidRefCT = mrTumorCentroid + mr2ct;


[mrTumorCloseVIdx, ~, distances] = closestNvertices(mrVRefCT, mrTumorCentroidRefCT, 3);
% % New method: one of the points for trilateration is the closest nipple
% mrTumorCloseVIdx(1) = closestNippleIdx;

mrDefTumorCloseV = mrVdef(mrTumorCloseVIdx, :);
[tumor1, tumor2] = trilateration(mrDefTumorCloseV(:,1), ...
                                            mrDefTumorCloseV(:,2), ...
                                            mrDefTumorCloseV(:,3), ...
                                            distances);
possibleTumors = [tumor1; tumor2];

% % Se elige el más posterior - NO, no tiene porqué ser el más posterior
% lo ideal sería tener una malla cerrada y
% usar inpolyhedron - NO, no va bien con mallas abiertas
% estimatedLocation = possibleTumors(inpolyhedron(ctF, ctV, possibleTumors), :);
% [~, i] = max(possibleTumors(:,2));
% estimatedLocation = possibleTumors(i, :);

% % Uso la bounding box de mrVdef - NO, quizá ambos estén dentro
% if (min(mrVdef(:,1)) < tumor1(1)) && (tumor1(1) < max(mrVdef(:,1))) && (min(mrVdef(:,2)) < tumor1(2)) && (tumor1(2) < max(mrVdef(:,2))) && (min(mrVdef(:,3)) < tumor1(3)) && (tumor1(3) < max(mrVdef(:,3)))
%     estimatedLocation = tumor1;
% else
%     estimatedLocation = tumor2;
% end

% % Se usa el más cercano al centroide de la malla por que es más probable
% % que esté dentro - NO, el centroide de los nodos puede estar lejos del
% %centroide de la ROI
% mrVdefCentroid = mean(mrVdef);
% distanceTumor1 = norm(tumor1 - mrVdefCentroid);
% distanceTumor2 = norm(tumor2 - mrVdefCentroid);
% [~, closestIdx] = min([distanceTumor1, distanceTumor2]);
% estimatedLocation = possibleTumors(closestIdx, :);

% Se usa más cercano al centro de la ROI de la malla deformada
roiCentroid = mean([min(mrVdef); max(mrVdef)]);
distanceTumor1 = norm(tumor1 - roiCentroid);
distanceTumor2 = norm(tumor2 - roiCentroid);
[~, closestIdx] = min([distanceTumor1, distanceTumor2]);
estimatedLocation = possibleTumors(closestIdx, :);

mrDefTumorV = mrTumorV - repmat(mrTumorCentroid, length(mrTumorV), 1) + repmat(estimatedLocation, length(mrTumorV), 1);

ctTumorCentroid = mean(ctTumorV);
ctTumorCloseVIdx = closestNvertices(ctV, ctTumorCentroid, 3);
% % New method:
% ctTumorCloseVIdx(1) = ctNipplesIdx(laterality);


fcsvwrite(fullfile(outputDir, 'possibleTumors'), possibleTumors, 'Tumor')
fcsvwrite(fullfile(outputDir, 'MR_closestVertices'), mrV(mrTumorCloseVIdx,:), 'Close vertices MR')
fcsvwrite(fullfile(outputDir, 'MR_def_closestVertices'), mrVdef(mrTumorCloseVIdx,:), 'Close vertices MR deformed')
fcsvwrite(fullfile(outputDir, 'CT_closestVertices'), ctV(ctTumorCloseVIdx,:), 'Close vertices CT')
