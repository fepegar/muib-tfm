function newFilename = forceExtension(filename, extension)

[dir, name, ext] = fileparts(filename);
if ~strcmp(ext, extension)
    newFilename = fullfile(dir, [name extension]);
else
    newFilename = filename;
end
