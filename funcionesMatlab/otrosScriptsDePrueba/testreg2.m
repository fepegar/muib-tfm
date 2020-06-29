
ctPath = 'maskedCt.nii';
mrPath = 'images/Serie_454.hdr';
mrMaskPath = 'images/maskRM.nii';

ctNii = load_nii(ctPath);
mrNii = load_nii(mrPath);
mrMaskNii = load_nii(mrMaskPath);

ct = imnorm(ctNii.img);
ct = ct(90:370, 260:350, 10:100);
mr = imnorm(mrNii.img);
mrMask = logical(mrMaskNii.img);
mrMask = flip(mrMask, 1);
mrMask = flip(mrMask, 2);
mr = mr(:,40:end,165:340);
ct = imresize3d(ct, 1/2);
mr = imresize3d(mr, 1/4);

myshowc(1,3,ct(:,:,25), mr(:,:,20), mrMask(:,:,230))



[Ireg,O_trans,Spacing,M,B,F] = image_registration(mr,ct);
beep

myshow(1,3,ct(:,:,25), mr(:,:,20), x(:,:,20))
