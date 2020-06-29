function voxel = ras2ijk(point, img)

% Parse point input and convert it to homogeneous if necessary
[rows, columns] = size(point);
if columns > rows
    point = point';
end

if length(point) == 3
    pointHomo = [point; 1];
elseif length(point) == 4
    pointHomo = point;
end

ijk2lps = img.ijkToLpsTransform;
lps2ijk = inv(ijk2lps);

ras2ijk = lps2ijk;
ras2ijk(1:2,1:2) = - ras2ijk(1:2,1:2);

vIJKHomo = round(ras2ijk * pointHomo);

voxel = vIJKHomo(1:3);