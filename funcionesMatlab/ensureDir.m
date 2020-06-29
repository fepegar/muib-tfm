function ensureDir(dirName)
if ~ exist(dirName, 'dir')
    mkdir(dirName)
end