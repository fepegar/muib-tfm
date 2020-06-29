function [resdouble01, res8] = imnorm(im)

%IMNORM Normalize image.
%
%   B = imnorm(A) returns image B that is image A with values rescaled
%   bewtween 0 and 1.
%
%   [B, C] = imnorm(A) returns image B that is image A with values rescaled
%   bewtween 0 and 1 and image C that is image A with values rescaled
%   bewtween 0 and 255;
%
%   Example:
%      B = imnorm(A);
%      imshow(B)
%
%   See also RGB.

%   Fernando Pérez-García
%   March 2015

im = double(im);
im = im - min(im(:));
resdouble01 = im / max(im(:));
res8 = uint8(255*resdouble01);