function deleteManta(filename, n)

% n = size of strel for the dilation

ctNii = load_nii(filename);
ct = ctNii.img;
ctNorm = imnorm(ct);
t = multithresh(ctNorm,2);
t = t(2);
manta = ctNorm > t;
manta = largestregion(manta);
if nargin == 1
    n = 30;
end
manta = imdilate(manta, ones(n,n,n));
ct(manta) = min(ct(:));

[dir, name, ext] = fileparts(filename);

newFilename = fullfile(dir, ['edited_' int2str(n) '_' name ext]);
ctNii.img = ct;

save_nii(ctNii, newFilename)