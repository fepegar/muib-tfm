
clc

p = '/Users/fernando/Dropbox/MUIB/TFM/data/results_random_trilateration.csv';

data = csvread(p,2,2);

data = data(1:3, 1:6);
data = reshape(data, 18,1)

%%
close all

group = {'Symmetrize Free Conformal', 'Normalize Free Combinatorial', 'Symmetrize Free Combinatorial'}';

group = repmat(group, 6, 1);

x = reshape(repmat(1:6, 3, 1), 18, 1);

gscatter(x,data,group, 'rgb', '.x+', [30 10 10])
ax = gca;
ax.XTick = 1:6;
ax.XTickLabel = {'0','3','4','5','6','9'};
grid minor

xlabel('Caso')
ylabel('Error (mm)')

line(xlim, [15 15], 'Color', 'k')



%%


