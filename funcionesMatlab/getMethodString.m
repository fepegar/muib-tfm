function string = getMethodString(inputParams)

strings = {};

if isfield(inputParams, 'symmetrize')
    strings{end+1} = 'Symmetrize';
end

if isfield(inputParams, 'normalize')
    strings{end+1} = 'Normalize';
end

strings{end+1} = inputParams.deformationBoundary;

if strfind('Point between nipples', inputParams.initialization)
    initialization = 'NipplesCenter';
elseif strfind('Mesh centroid', inputParams.initialization)
    initialization = 'Centroid';
end
strings{end+1} = initialization;

strings{end+1} = inputParams.deformationLaplacian;

string = strjoin(strings, '_');