
p = '/Users/fernando/Desktop/Parula.txt';
fid = fopen(p, 'w');

fprintf(fid, '#Begin table data:\n');

for i = 1:length(a)
    color = round(255 * a(i,:));
    fprintf(fid, '%d %d %d %d %d 255\n', ...
            i, i, color(1), color(2), color(3));
end

fclose(fid);


