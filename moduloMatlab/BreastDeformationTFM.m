function outputParams = BreastDeformationTFM(inputParams)

tic;
save ('inputParams', 'inputParams')

%% Directories
if isfield(inputParams, 'patientID')
    patientDir = fullfile(inputParams.dataDir, sprintf('caso_%d', inputParams.patientID));
    sceneDir = fullfile(patientDir, 'mrml');
    resultsDir = fullfile(sceneDir, 'results');
    methodString = getMethodString(inputParams);
    methodDir = fullfile(resultsDir, methodString);
    fiducialsDir = fullfile(methodDir, 'fiducials');
    measurementsPath = fullfile(methodDir, 'measurements.csv');

    ensureDir(resultsDir)
    ensureDir(methodDir)
    ensureDir(fiducialsDir)
else
    fiducialsDir = '';
    measurementsPath = '';
end

%% Load or create surfaces
% Cannot use strcmp because only the first word is received
% Note: happens on Mac, not on Windows. Linux?
if strfind('B: generate mesh from input volume', inputParams.mrMeshEnumeration) == 1
    mr = cli_imageread(inputParams.mrInputVolume);    
    mrROIras = inputParams.mrROI;
    [mrV, mrF] = getSurfaceFromMR(mr, mrROIras);
elseif strfind('A: use existing mesh', inputParams.mrMeshEnumeration) == 1
    [mrV, mrF] = read_ply(inputParams.mrSurfaceMeshIn);
else
    error('Prone mesh generation method cannot be read: "%s".', inputParams.mrMeshEnumeration)
end

if isfield(inputParams, 'mrResample')
    [mrV, mrF] = meshresample(mrV, mrF, inputParams.mrNumberOfNodes / length(mrV));
end

times.t_meshMR = toc;tic;


if strfind('B: generate mesh from input volume', inputParams.ctMeshEnumeration) == 1
    ct = cli_imageread(inputParams.ctInputVolume);
    ctROIras = inputParams.ctROI;
    [ctV, ctF] = getSurfaceFromCT(ct, ctROIras);
elseif strfind('A: use existing mesh', inputParams.ctMeshEnumeration) == 1
    [ctV, ctF] = read_ply(inputParams.ctSurfaceMeshIn);
else
    error('Supine mesh generation method cannot be read: "%s".', inputParams.ctMeshEnumeration)
end

if isfield(inputParams, 'ctResample')
    [ctV, ctF] = meshresample(ctV, ctF, inputParams.ctNumberOfNodes / length(ctV));
end

times.t_meshCT = toc;tic;



%% Deformation

% Read nipples fiducials lists
if iscell(inputParams.mrFiducials)
    mrNipplesFiducials = cell2mat(inputParams.mrFiducials)'; % 2 x 3
else
    mrNipplesFiducials = inputParams.mrFiducials;
end

if iscell(inputParams.ctFiducials)
    ctNipplesFiducials = cell2mat(inputParams.ctFiducials)'; % 2 x 3
else
    ctNipplesFiducials = inputParams.ctFiducials;
end

mrNipplesIdx = closestvertices(mrV, mrNipplesFiducials);
ctNipplesIdx = closestvertices(ctV, ctNipplesFiducials);


% Calculate fiducials for deformation
if strfind('Point between nipples', inputParams.initialization)
    initialization = 'centralPoints';
elseif strfind('Mesh centroid', inputParams.initialization)
    initialization = 'centroids';
end

distanceBetweenPoints = inputParams.distanceBetweenFiducials;

[mrFiducials, mrColors, ctFiducials, ctColors, mr2ctMatrix, mrPointBetweenNipples] = fiducialsGeodesicLines(mrV, mrF, mrNipplesIdx, ctV, ctF, ctNipplesIdx, distanceBetweenPoints, initialization, fiducialsDir);

times.t_geodesicFiducials = toc;tic;


% Actual deformation
mrVdef = breastDeformation(mrV, mrF, ctV, ...
                              mrFiducials, ctFiducials, ...
                              inputParams.deformationLaplacian, ...
                              isfield(inputParams, 'symmetrize'), ...
                              isfield(inputParams, 'normalize'), ...
                              inputParams.deformationBoundary, ...
                              mr2ctMatrix);                         

times.t_deformation = toc;tic;

%% Tumor location estimation

if strfind('A: mesh from segmentation', inputParams.mrTumorType) == 1
    [mrTumorV, mrTumorF] = read_ply(inputParams.mrTumorSegmented);
    mrTumorCentroid = mean(mrTumorV);
elseif strfind('B: sphere from fiducial list', inputParams.mrTumorType) == 1
    mrTumorCentroid = inputParams.mrTumorFiducial'; % 1 x 3
    [mrTumorV, mrTumorF] = spheremesh(mrTumorCentroid, inputParams.tumorRadius, 60);
else
    error('Tumor mesh generation method cannot be read: "%s".', inputParams.tumorEnumeration)
end

if strfind('A: mesh from segmentation', inputParams.ctTumorType) == 1
    [ctTumorV, ctTumorF] = read_ply(inputParams.ctTumorSegmented);
    ctTumorCentroid = mean(ctTumorV);
elseif strfind('B: same mesh as supine', inputParams.ctTumorType) == 1
    ctTumorCentroid = inputParams.ctTumorFiducial'; % 1 x 3
    ctTumorV = mrTumorV;
    ctTumorF = mrTumorF;
    ctTumorV = ctTumorV - repmat(mrTumorCentroid, length(mrTumorV), 1) + repmat(ctTumorCentroid, length(mrTumorV), 1);
end

[estimatedTumorV, estimatedTumorPoint] = tumorEstimation(mrV, ...
                                                    mrNipplesIdx, ...
                                                    ctV, ...
                                                    ctNipplesIdx, ...
                                                    mrVdef, ...
                                                    mr2ctMatrix, ...
                                                    mrTumorCentroid, ...
                                                    mrTumorV, ...
                                                    ctTumorV, ...
                                                    fiducialsDir);

times.t_tumor = toc;tic;


%% Write output

if fiducialsDir
    fcsvwrite(fullfile(fiducialsDir, 'MR_deformation_fiducials'), mrFiducials, '')
    fcsvwrite(fullfile(fiducialsDir, 'CT_deformation_fiducials'), ctFiducials, '')
end
    
% For some reason, Slicer inverts the S coordinate
% ITK convention? Something related to images in LPS by default
% when using MatlabBridge extension?
mr2ctMatrix(3, 4) = -mr2ctMatrix(3, 4);


if strcmp('All', inputParams.meshWriteEnumeration)

    if isfield(inputParams, 'ctSurfaceMesh')
        my_write_ply(ctV, ctF, inputParams.ctSurfaceMesh, ctColors)
    end
    if isfield(inputParams, 'mrSurfaceMesh')
        my_write_ply(mrV, mrF, inputParams.mrSurfaceMesh, mrColors)
    end
    if isfield(inputParams, 'mrDeformed')
        my_write_ply(mrVdef, mrF, inputParams.mrDeformed, mrColors)
    end
    if isfield(inputParams, 'mr2ctTransform')
        cli_lineartransformwrite(inputParams.mr2ctTransform, mr2ctMatrix)
    end
    if isfield(inputParams, 'estimatedTumor')
        write_ply(estimatedTumorV, mrTumorF, inputParams.estimatedTumor)
    end
    if isfield(inputParams, 'ctTumorWrite')
        write_ply(ctTumorV, ctTumorF, inputParams.ctTumorWrite)
    end
    if isfield(inputParams, 'mrTumorWrite')
        write_ply(mrTumorV, mrTumorF, inputParams.mrTumorWrite)
    end

elseif strfind('Only deformed and tumor', inputParams.meshWriteEnumeration) == 1
    if isfield(inputParams, 'mrDeformed')
        my_write_ply(mrVdef, mrF, inputParams.mrDeformed, mrColors)
    end
    if isfield(inputParams, 'mrTumorDeformed')
        my_write_ply(estimatedTumorV, mrTumorF, inputParams.mrTumorDeformed, 0)
    end
elseif strcmp(inputParams.meshWriteEnumeration, 'matlabTests')
    % Para validar TFM
    addpath('/Applications/Slicer.app/Contents/Extensions-23774/MatlabBridge/lib/Slicer-4.4/cli-modules/commandserver')
    write_ply(estimatedTumorV, mrTumorF, inputParams.mrTumorDeformed)
    my_write_ply(ctV, ctF, inputParams.ctSurfaceMeshIn, ctColors)
    my_write_ply(mrV, mrF, inputParams.mrSurfaceMeshIn, mrColors)
    my_write_ply(mrVdef, mrF, inputParams.mrDeformed, mrColors)
    write_ply(ctTumorV, ctTumorF, inputParams.ctTumorWrite)
    write_ply(mrTumorV, mrTumorF, inputParams.mrTumorWrite)
    cli_lineartransformwrite(inputParams.mr2ctTransform, mr2ctMatrix)
end

outputParams.error = num2str(norm(ctTumorCentroid - estimatedTumorPoint), '%.1f');

times.t_writeMeshes = toc;
times.t_total = sum(struct2array(times));

% Write times
fields = fieldnames(times);
for i = 1:numel(fields)
    eval(sprintf('outputParams.%s = num2str(times.%s, 3);', fields{i}, fields{i}))
end

if measurementsPath
    fid = fopen(measurementsPath, 'w');
    fprintf(fid, 'Patient ID,Nodes MR,Nodes CT,Distance to tumor (mm),Total computation time (s)\n');
    fprintf(fid, sprintf('%d,%d,%d,%s,%.1f', inputParams.patientID, length(mrV), length(ctV), outputParams.error, times.t_total));
    fclose(fid);
end

