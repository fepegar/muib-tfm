clc, clear


casos = [3 4 5 6 9];

for i = 1:5
    caso = casos(i);

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

    opacity = .2;

    ctColors = 14*ones(length(ctV),1);
    ctColors(1) = 20;
    ctColors(2) = 0;

    optCT.face_vertex_color = ctColors;
    optCT.opacity = opacity;

    optMR.face_vertex_color = 4*ones(length(mrV),1);
    optMR.opacity = opacity;

    optTumorCT.face_vertex_color = 8*ones(length(ctTumorV),1);

    optTumorMR.face_vertex_color = 18*ones(length(mrTumorV),1);


    close all

    time = 4;
    fps = 25;
    filename = sprintf('/Users/fernando/Dropbox/MUIB/TFM/capturas/gifCaso%d.gif', caso);

    frames = time * fps;
    tFrame = time/frames;

    figure('visible','off')
    set(gcf,'color','white')

    h = waitbar(0, sprintf('Paciente %d', caso));
    for t = 0:frames-1
        clf
        mrVActual = mrV + t/(frames-1) * (mrDefV - mrV);
        mrTumorVActual = mrTumorV + t/(frames-1) * (mrTumorDefV - mrTumorV);
        mrNipplesActual = mrVActual(mrNipplesIdx, :);

        plot_mesh(mrVActual,mrF,optMR);
        plot_mesh(mrTumorVActual, mrTumorF, optTumorMR);
        plot_mesh(ctV, ctF, optCT);
        plot_mesh(ctTumorV, ctTumorF, optTumorCT);
        colormap(jet(20))
        hold on
        scatter3(mrNipplesActual(:,1), mrNipplesActual(:,2), mrNipplesActual(:,3), 50, 'filled')
        scatter3(ctNipples(:,1), ctNipples(:,2), ctNipples(:,3), 50, 'filled')
        img = getframe(gcf);
        
        if t == 0
            a = rgb2gray(img.cdata);
            [r, c] = find(a < 255);
        end
        img = img.cdata;
        img = img(min(r):max(r), min(c):max(c), :);
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
end

beep
beep