function mask = myfillholes3d(mask)
for i = 1:size(mask,3)
    mask(:,:,i) = imfill(mask(:,:,i), 'holes');
end