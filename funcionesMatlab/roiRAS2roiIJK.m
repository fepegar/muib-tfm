function roiVoxels = roiRAS2roiIJK(roi, img)

roiCenter = roi(1:3);
roiLengths = roi(4:6);
pIni = zeros(1,3);
pFin = zeros(1,3);
for i = 1:3
    pIni(i) = roiCenter(i) - roiLengths(i);
    pFin(i) = roiCenter(i) + roiLengths(i);
end

roiVoxels = [ras2ijk(pIni, img)'; ras2ijk(pFin, img)'];

for dimension = 1:3
    roiVoxels(:,dimension) = sort(roiVoxels(:,dimension));
end
    

dimImg = size(img.pixelData);

for dimension = 1:3
    roiVoxels(1, dimension) = max(roiVoxels(1, dimension), 1);
    roiVoxels(2, dimension) = min(roiVoxels(2, dimension), dimImg(dimension));
end  
    
