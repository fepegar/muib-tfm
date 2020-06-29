function fiducials = fcsvread(filepath)

fid = fopen(filepath);

assert(fid >= 3, 'The file could not be opened. fid = %d', fid)

allData = textscan(fid,'%s','Delimiter','\n');
allData = allData{1};

numFiducials = numel(allData) - 3;
fiducials = zeros(numFiducials, 3);
for i = 1 : numFiducials
    list = strsplit(allData{i + 3}, ',');
    fiducials(i,:) = str2double(list(2:4));
end

fclose(fid);