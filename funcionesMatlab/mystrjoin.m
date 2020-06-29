function res = mystrjoin(strings, delim)

% In new MATLAB versions, there is a strjoin() function.

res = [];
for i = 1:numel(strings)
    s = strings{i};
    res = [res s delim];
end

res = res(1:end-1);