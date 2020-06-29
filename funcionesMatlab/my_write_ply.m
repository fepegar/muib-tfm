function my_write_ply(vertex,face,filename, scalars)

% options.verbose = 0;
% [Umin,Umax,Cmin,Cmax,Cmean,Cgauss,Normal] = compute_curvature(vertex,face,options);
% face_vertex_color=perform_saturation(Cgauss, 1);
% [~, a] = imnorm(face_vertex_color);
% scalars = a;

writeScalars = false;
if length(scalars) == length(vertex)
    writeScalars = true;
end

fileID = fopen(filename,'w');

strings = {'ply', ...
           'format ascii 1.0', ...
           'comment author: Fernando Perez-Garcia', ...
           sprintf('element vertex %d', length(vertex)), ...
           'property float x', ...
           'property float y', ...
           'property float z', ...
           'property uchar red', ...
           'property uchar green', ...
           'property uchar blue', ...
           sprintf('element face %d', length(face)), ...
           'property list uchar int vertex_indices', ...
           'end_header'};

       
stringsToPrint = 1:numel(strings);
if ~writeScalars
    stringsToPrint(8:10) = [];
end
for i = stringsToPrint
    fprintf(fileID, '%s\n', strings{i});
end

for nVertex = 1:length(vertex)
    fprintf(fileID, '%f %f %f', ...
                    vertex(nVertex, 1), ...
                    vertex(nVertex, 2), ...
                    vertex(nVertex, 3));
    if writeScalars
        fprintf(fileID, ' %d 0 0', scalars(nVertex));
    end
    
    fprintf(fileID, '\n');
    
end

% El -1 es para que indexe como el resto de programas que no son MATLAB
for nFace = 1:length(face)
    fprintf(fileID, '3 %d %d %d\n', ...
                    face(nFace, 1) - 1, ...
                    face(nFace, 2) - 1, ...
                    face(nFace, 3) - 1);
end

fclose(fileID);
