

close all
for i = 1:3
    f = fillholes3d(a,i);
    f = imopen(f, nei);
    n = make_nii(uint8(f));
    save_nii(n,['maskTest' int2str(i) '.nii']);
end

