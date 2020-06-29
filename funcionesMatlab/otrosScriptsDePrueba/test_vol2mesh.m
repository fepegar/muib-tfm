clc, clear, close all

ctPath = 'images/RIO_42_PRE_CT_220909.hdr';
mrPath = 'images/Serie_454.hdr';
mrMaskPath = 'images/maskRM.nii';

ctNii = load_nii(ctPath);
mrNii = load_nii(mrPath);
mrMaskNii = load_nii(mrMaskPath);

ct = imnorm(ctNii.img);
mrMask = logical(mrMaskNii.img);

%% Aumento del contraste MRI
% for i = 1:size(mr, 3)
%     mr(:,:,i) = imadjust(mr(:,:,i), );
% end

%% Umbralizar
thresh = multithresh(ct, 2);
ctMask = ct > thresh(2);

% mrMaskNoise = mr > graythresh(mr);

%% Fill holes CT
ctMask = fillholes3d(ctMask, 10);
% implay(ctMask)

%% Fill holes MRI
% mrMaskNoise = imclose(mrMaskNoise, strel('disk', 3));

mrMaskFilled = false(size(mrMask));
for i = 1:size(mrMask, 3)
    mrMaskFilled(:,:,i) = imfill(mrMask(:,:,i), 'holes');
end

% mrMaskFilled = fillholes3d(mrMask, 10);
myshowc(mrMaskFilled(:,:,245))
% myshow(imadjust(mr(:,:,245)))
% myshow(mrMaskNoise (:,:,245))
% myshow(mrMaskFilled(:,:,245))

% % close all
% % for i = 1:10:101
% %     disp(int2str(i))
% %     mrMaskFilled = fillholes3d(mrMask, 10);
%     myshow(mrMaskFilled(:,:,240))
% %     title(int2str(i))
% % end

%% Mesh CT
% [lx, ly, lz] = size(ct);
% [noCt,elCt,regionsCt,holesCt] = vol2surf(... 
%     ctMask, ...
%     1:lx, ...
%     256:ly, ...
%     1:lz, ...
%     1/20, ...
%     1, ...
%     'simplify');

%% Mesh MRI

[lx, ly, lz] = size(mrMask);
[noMr,elMr,regionsMr,holesMr] = vol2surf(... 
    mrMaskFilled, ...
    1:lx, ...
    1:ly, ...
    1:lz, ...
    1, ...
    1, ...
    'simplify');

plotmesh(noMr,elMr)


%% Eliminar pared CT

% cent = meshcentroid(noCt,elCt(:,1:3));
% x = cent(:,1);
% y = cent(:,2);
% z = cent(:,3);
% idx = find(x > 90);
% idx = intersect(idx, find(y > 260));
% idx = intersect(idx, find(z < 100));
% idx = intersect(idx, find(z > 10));
% elCt2 = elCt(idx, :);
% [noCt, elCt2] = meshcheckrepair(noCt, elCt2, 'isolated');


%% Eliminar pared MR

cent = meshcentroid(noMr,elMr(:,1:3));
x = cent(:,1);
y = cent(:,2);
z = cent(:,3);
idx = find(x > 15);
idx = intersect(idx, find(y < 120));
% idx = intersect(idx, find(z > 165));
% idx = intersect(idx, find(z > 10));
elMr2 = elMr(idx, :);

[noMr, elMr2] = meshcheckrepair(noMr, elMr2, 'isolated');



% Transf

pixdim = mrMaskNii.hdr.dime.pixdim;
dx = pixdim(2);
dy = pixdim(3);
dz = pixdim(4);

% Origen en 0,0,0
qform = repmat([dx dy dz], length(noMr), 1);

noMrTransf = noMr;

% Traslación apaño
noMrTransf(:,1) = noMrTransf(:,1) - size(mrMask, 1);
noMrTransf(:,2) = noMrTransf(:,2) - size(mrMask, 2);

% Escalado
noMrTransf = noMrTransf .* qform;



write_ply(noMrTransf,elMr2(:,1:3),'mrNew.ply');

plotmesh(noMr,elMr2)

%% Transformar de acuerdo con imagen

pixdim = ctNii.hdr.dime.pixdim;
dx = -pixdim(2);
dy = -pixdim(3);
dz = pixdim(4);

% Origen en 0,0,0
qform = repmat([dx dy dz], length(noCt), 1);

noCt = noCt .* qform;

%% Mostrar mesh

% plotmesh(no,el,'y>260')
plotmesh(noCt,elCt2)

%% Guardar

write_ply(noCt,elCt2(:,1:3),'ct.ply');



