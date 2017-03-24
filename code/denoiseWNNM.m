clear all
close all
global rs cs brs bcs patchNum  patchLen c eps noiseVar
noiseVar=0.1;
rawImage=imread(['E:/毕设/code/lena/', num2str(noiseVar), '.jpg']);
image=double(rawImage);
[rs, cs]=size(image);
brs=32;bcs=32;patchLen=brs*bcs;
patchNum=10; %允许的最大match patch数目
%计算权值时的参数
c=2.8;
eps=10e-16;   %防止除以0 
K=1;   %迭代处理次数
delta=0.1;  %迭代处理的增量

denoImage=image;    %最终得到的去噪图像
tempImage=image;    %去噪中间步骤的图像
tic;
for k=1:K
    tempImage=denoImage+delta*(image-tempImage);    %iterative regularization
    denoImage=wnnm(tempImage);
end
toc;
denoImage=uint8(round(denoImage));
figure(1);
title('before');
imshow(rawImage);
figure(2);
title('after');
imshow(denoImage);
        
        
        
        

