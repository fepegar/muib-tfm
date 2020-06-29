addpath('/Applications/Slicer.app/Contents/Extensions-23774/MatlabModules')

load inputParams % In order not to set the default values again

inputParams.meshWriteEnumeration = 'matlabTests';

patients = [0 3:6 9];
patients = 6;

numPatients = length(patients);

dataDir = '/Users/fernando/Dropbox/MUIB/TFM/data';
mrNipples = 'MR_nipples.fcsv';
mrMesh = 'Output surface MR.ply';
ctNipples = 'CT_nipples.fcsv';
ctMesh = 'Output surface CT.ply';
mrTumorMesh = 'MR_tumor.ply';
ctTumorMesh = 'CT_tumor.ply';
mrDeformed = 'Deformed MR mesh.ply';
mrTumorDeformed = 'Tumor in deformed MRI space.ply';

ff = @fullfile;

%%
h = waitbar(0);
m = 1;
for i = 1:numPatients
    patient = patients(i);
    patientDir = ff(dataDir, ['caso_' int2str(patient)]);
    mrmlDir = ff(patientDir, 'mrml');
    sourceDir = ff(mrmlDir, 'source');
    resultsDir = ff(mrmlDir, 'results');
    
    inputParams.patientID = patient;
    inputParams.mrFiducials = fcsvread(ff(sourceDir, mrNipples));
    inputParams.mrSurfaceMeshIn = ff(sourceDir, mrMesh);
    inputParams.ctFiducials = fcsvread(ff(sourceDir, ctNipples));
    inputParams.ctSurfaceMeshIn = ff(sourceDir, ctMesh);
    inputParams.mrTumorSegmented = ff(sourceDir, mrTumorMesh);
    inputParams.ctTumorMeshSegmented = ff(sourceDir, ctTumorMesh);
    
    inputParams.symmetrize = '';
    inputParams.normalize = '';
    
    for sm = 1:3 % Sym Norm
        switch sm
            case 2 % only sym
                inputParams = rmfield(inputParams, 'normalize');
            case 3 % only norm
                inputParams = rmfield(inputParams, 'symmetrize');
                inputParams.normalize = '';
        end
        
        for bo = 1:2
            switch bo
                case 1
                    inputParams.deformationBoundary = 'Free';
                    numIni = 1;
                case 2
                    inputParams.deformationBoundary = 'Fixed';
                    numIni = 2;
            end
            
            for ini = 1:numIni
                switch ini
                    case 1
                        inputParams.initialization = 'Mesh';
                    case 2
                        inputParams.initialization = 'Point';
                end
                
                for lap = 1:3
                    switch lap
                        case 1
                            inputParams.deformationLaplacian = 'Combinatorial';
                        case 2
                            inputParams.deformationLaplacian = 'Distance';
                        case 3
                            inputParams.deformationLaplacian = 'Conformal';
                    end
                    
                    methodString = getMethodString(inputParams);
                    methodDir = ff(resultsDir, methodString);
                    modelsDir = ff(methodDir, 'models');
                    ensureDir(modelsDir)
                    
                    inputParams.mrDeformed = ff(modelsDir, mrDeformed);
                    inputParams.mrTumorDeformed = ff(modelsDir, mrTumorDeformed);
                    
                    waitbar(m/(27*numPatients), sprintf('Patient %d, method %s', patientID, methodString))
                    BreastDeformationTFM(inputParams);
                end
            end
        end
    end
end

close(h)

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    