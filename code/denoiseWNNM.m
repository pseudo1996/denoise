clear all
close all
global rs cs brs bcs patchNum  patchLen c eps noiseVar
noiseVar=0.1;
rawImage=imread(['E:/����/code/lena/', num2str(noiseVar), '.jpg']);
image=double(rawImage);
[rs, cs]=size(image);
brs=32;bcs=32;patchLen=brs*bcs;
patchNum=10; %���������match patch��Ŀ
%����Ȩֵʱ�Ĳ���
c=2.8;
eps=10e-16;   %��ֹ����0 
K=1;   %������������
delta=0.1;  %��������������

denoImage=image;    %���յõ���ȥ��ͼ��
tempImage=image;    %ȥ���м䲽���ͼ��
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
        
        
        
        
