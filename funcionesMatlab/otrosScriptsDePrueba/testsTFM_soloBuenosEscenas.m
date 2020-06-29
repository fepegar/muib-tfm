addpath('/Applications/Slicer.app/Contents/Extensions-23774/MatlabModules')

load inputParams % In order not to set the default values again

inputParams.meshWriteEnumeration = 'matlabTests';
if isfield(inputParams, 'ctResample')
    inputParams = rmfield(inputParams, 'ctResample');
end
if isfield(inputParams, 'mrResample')
    inputParams = rmfield(inputParams, 'mrResample');
end

patients = [0 3:6 9];
% patients = 0;

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

ctTumorWrite = 'Tumor segmented on CT.ply';
mrTumorWrite = 'Tumor in MRI space.ply';
mr2ctTransform = 'MRI to CT transform.txt';

ff = @fullfile;

%%
h = waitbar(0);
m = 1;
for i = 1:numPatients
    patientID = patients(i);
    patientDir = ff(dataDir, ['caso_' int2str(patientID)]);
    mrmlDir = ff(patientDir, 'mrml');
    sourceDir = ff(mrmlDir, 'source');
    resultsDir = ff(mrmlDir, 'results');
    
    inputParams.patientID = patientID;
    inputParams.mrFiducials = fcsvread(ff(sourceDir, mrNipples));
    inputParams.mrSurfaceMeshIn = ff(sourceDir, mrMesh);
    inputParams.ctFiducials = fcsvread(ff(sourceDir, ctNipples));
    inputParams.ctSurfaceMeshIn = ff(sourceDir, ctMesh);
    inputParams.mrTumorSegmented = ff(sourceDir, mrTumorMesh);
    inputParams.ctTumorSegmented = ff(sourceDir, ctTumorMesh);
    
    inputParams.deformationBoundary = 'Free';
    inputParams.initialization = 'Mesh';
    
    inputParams.symmetrize = '';
    inputParams.normalize = '';
    
    for sm = 1:2 % Sym Norm
        switch sm
            case 1 % only sym
                inputParams = rmfield(inputParams, 'normalize');
            case 2 % only norm
                inputParams = rmfield(inputParams, 'symmetrize');
                inputParams.normalize = '';
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
            inputParams.ctTumorWrite = ff(modelsDir, ctTumorWrite);
            inputParams.mrTumorWrite = ff(modelsDir, mrTumorWrite);
            inputParams.mr2ctTransform = ff(modelsDir, mr2ctTransform);

            waitbar(m/(6*numPatients), h, sprintf('Patient %d, method %s', patientID, methodString))
            m = m+1;
            BreastDeformationTFM(inputParams);
        end
    end
end

close(h)

for i = 1:3
    beep
    pause(.5)
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    