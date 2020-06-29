% 
% [x, y, z] = size(mrMask);
% tr = zeros(x,y,z,3);
% 
% for i = 1:length(noMr)
%     voxel = round(noMr(i, :));
%     tr(voxel(1), voxel(2), voxel(3), :) = Transform.Y(i, :) - MR(i, :);
% end


x=flip(mr,2);
x=flip(x,1);
x(~mrMaskFilled) = 0;


[sx, sy, sz] = size(ct);
y=ct;
y(~ctMask) = 0;
y(1:90,:,:)  = zeros(90,sy,sz);
y(:,1:260,:) = zeros(sx,260,sz);
y(:,:,1:10) = zeros(sx,sy,10);
y(:,:,100:end) = zeros(sx,sy,sz-100+1);



for i = 40:10:80
    close all
    myshow(1,2,y(:,:,i),ct(:,:,i))
    title(i)
    pause
end
close