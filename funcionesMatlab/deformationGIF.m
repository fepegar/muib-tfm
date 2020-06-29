function deformationGIF(vIni, vFin, faces, time, fps, filename, rotate)

    frames = time * fps;

    tFrame = time/frames;

    close all

    el = linspace(90,-65,frames);

    figure('visible','off')
    set(gcf,'color','white')
    h = waitbar(0, 'Making GIF...');
    for t = 0:frames-1
        clf
        v = vIni + t/(frames-1) * (vFin - vIni);
%         distancesDeformation = sqrt(sum((v-vIni).^2, 2));
%         distancesDeformation = round(distancesDeformation / max(distancesDeformation) * 255);
        if rotate
            pm(v,faces, el(t+1));
        else
            pm(v,faces);
        end
        img = getframe(gcf);
        img = img.cdata;
        img = img(60:320, 100:480, :);
        [a, map] = rgb2ind(img, 256);
        if t == 1
            imwrite(a,map,filename,'gif','LoopCount',Inf,'DelayTime',tFrame*5);
        elseif t > 1
            imwrite(a,map,filename,'gif','WriteMode','append','DelayTime',tFrame);
        end
        waitbar((t+1) / frames, h)
    end
    imwrite(a,map,filename,'gif','WriteMode','append','DelayTime',2);
    close(h)
    close all
    beep
end


function pm(v,f,el)

    az = 180;

    if nargin < 3
        az = -25;
        el = 35;
    end

%     opt.face_vertex_color = d;

%     xlims = [-600 -100];
%     ylims = [-600 -200];
%     zlims = [0 220];

    plot_mesh(v,f);
    view(az,el), camlight, axis off
%     xlim(xlims)
%     ylim(ylims)
%     zlim(zlims)
    colormap parula
end