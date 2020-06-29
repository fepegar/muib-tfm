function [mrVdef, distancesDeformation, mse] = breastDeformation(mrV, mrF, ctV, ...
                                          mrFiducials, ctFiducials, ...
                                          method, symmetrize, ...
                                          normalize, boundary, ...
                                          mr2ctMatrix)
                                      
deformedIdx = closestvertices(mrV, mrFiducials);

[~, finalVertices] = closestvertices(ctV, ctFiducials);

mr2ct = mr2ctMatrix(1:3, 4)';
mrVRefCT = mrV + repmat(mr2ct, length(mrV), 1);

clear options
options.symmetrize = symmetrize;
options.normalize = normalize;
L = compute_mesh_laplacian(mrVRefCT, mrF, lower(method), options);

if strcmpi(boundary, 'free')
    [mrVdef] = MeshLaplacianDeform(L, ...
                                   mrVRefCT, ...
                                   finalVertices, ...
                                   deformedIdx, ...
                                   []);
elseif strcmpi(boundary, 'fixed')
    m = makeMesh(mrV, mrF);
    verticesIdx = m.vidx;
    mrB = verticesIdx(logical(m.isboundaryv), :);
    [mrVdef] = MeshLaplacianDeform(L, ...
                                   mrVRefCT, ...
                                   finalVertices, ...
                                   deformedIdx, ...
                                   mrB);
else
    error('Unknown boundary parameter.')
end

distancesDeformation = sqrt(sum((mrVdef - mrVRefCT).^2, 2));

mse = mean(sqrt(sum((finalVertices - mrVdef(deformedIdx,:)).^2, 2)));