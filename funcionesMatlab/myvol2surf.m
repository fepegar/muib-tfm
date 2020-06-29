function [v, f] = myvol2surf(mask, ranges, simplify, n)

aux = false(size(mask));
aux(ranges{1}, ranges{2}, ranges{3}) = mask(ranges{1}, ranges{2}, ranges{3});
mask = aux;

fv = isosurface(mask, 0);
v = fv.vertices;
f = fv.faces;

if nargin > 2
    switch simplify
        case 'keepratio'
            [v, f] = meshresample(v, f, 1/n);
        case 'elements'
            [v, f] = meshresample(v, f, n/length(v));
    end
end
    
% Por el indexing de MATLAB?
v(:,[1 2]) = v(:, [2 1]);