





caso = 3;

s = sprintf('/Users/fernando/Dropbox/MUIB/TFM/data/caso_%d/mrml/source', caso);
r = sprintf('/Users/fernando/Dropbox/MUIB/TFM/data/caso_%d/mrml/results/Symmetrize_Free_Centroid_Conformal/models', caso);

%%
[mrV, mrF] = read_ply(fullfile(s, 'Output surface MR.ply'));
[ctV, ctF] = read_ply(fullfile(s, 'Supine large.ply'));
[mrTumorV, mrTumorF] = read_ply(fullfile(s, 'MR_tumor.ply'));
[mrDefV, mrDefF] = read_ply(fullfile(r, 'Deformed MR mesh.ply'));
[mrTumorDefV, mrTumorDefF] = read_ply(fullfile(r, 'Tumor in deformed MRI space.ply'));
[ctTumorV, ctTumorF] = read_ply(fullfile(s, 'CT_tumor.ply'));
mrNipples = fcsvread(fullfile(s, 'MR_nipples.fcsv'));
ctNipples = fcsvread(fullfile(s, 'CT_nipples.fcsv'));
centers = fcsvread('/Users/fernando/Desktop/F.fcsv');
mr2ct = centers(1,:) - centers(2,:);
%%
ctNipples = ctV(closestvertices(ctV, ctNipples), :);
mrNipplesIdx = closestvertices(mrV, mrNipples);
mrV = mrV + repmat(mr2ct, length(mrV), 1);
mrTumorV = mrTumorV + repmat(mr2ct, length(mrTumorV), 1);

%%

roi(2) = max(mrV(:,1));
roi(1) = centers(1);
roi(3) = min(mrV(:,2));
roi(4) = max(mrV(:,2));
roi(5) = min(mrV(:,3));
roi(6) = max(mrV(:,3));
% [v,f] = cropMesh(mrV, mrF, roi);

close all
tumCT = mean(ctTumorV);
tumIni = mean(mrTumorV);
tumFin = mean(mrTumorDefV);


time = 4;
fps = 25;
filename = sprintf('/Users/fernando/Dropbox/MUIB/TFM/capturas/gifTrilatCaso%d.gif', caso);

frames = time * fps;
tFrame = time/frames;

figure('visible','off')
set(gcf,'color','white')

[closestVerticesIdx, closestVerticesCoordinates, distances] = closestNvertices(mrV, tumIni, 3);

h = waitbar(0, sprintf('Paciente %d', caso));

for t = 0:frames-1
    clf
    mrVActual = mrV + t/(frames-1) * (mrDefV - mrV);
    tumActual = tumIni + t/(frames-1) * (tumFin - tumIni);
    
    
    plot_mesh(mrVActual,mrF);

    hold on
    scatter3(tumActual(1), tumActual(2), tumActual(3), 200, 'r', 'filled')
    scatter3(closestVerticesCoordinates(:,1), closestVerticesCoordinates(:,2), closestVerticesCoordinates(:,3), 30, 'g', 'filled')
%     scatter3(tumCT(1), tumCT(2), tumCT(3), 200, 'g', 'filled')

    
    clear c
    for punto = 1:3
        for coord = 1:3
            closestVerticesCoordinates = mrVActual(closestVerticesIdx,:);
            c{coord} = [tumActual(coord) closestVerticesCoordinates(punto,coord)];
        end
        plot3(c{1}, c{2}, c{3}, 'y')
    end

    view(35,40)
    shading faceted
    campan(-3.5,1)
    zoom(2)
    colormap parula
    
    
    
    
    
    
    
    img = getframe(gcf);
        
    if t == 0
        a = rgb2gray(img.cdata);
        [r, c] = find(a < 255);
    end
    img = img.cdata;
    [a, map] = rgb2ind(img, 256);
    if t == 1
        imwrite(a,map,filename,'gif','LoopCount',Inf,'DelayTime',tFrame*10);
    elseif t > 1
        imwrite(a,map,filename,'gif','WriteMode','append','DelayTime',tFrame);
    end
    waitbar((t+1) / frames, h, sprintf('Paciente %d', caso))
end
imwrite(a,map,filename,'gif','WriteMode','append','DelayTime',2)
close(h)

beep
beep


close all


