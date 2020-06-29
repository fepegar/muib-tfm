function y = checkMeshDimension(x, dim)

% if dim == 1, then size(y) == 3xN
% if dim == 2, then size(y) == Nx3

if size(x, dim) ~= 3
        x = x';
end
if size(x, dim)~=3
    error('Array does not have correct format: %s', mat2str(size(x)));
end

y = x;