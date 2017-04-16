clear all
close all
global image... %原始含噪图像
       rs cs... %原图像的行数与列数
       prs pcs...   %patch的行数与列数
       rstep cstep... %为了加速，行与列的步进
       patchNum...  %block match中允许的最大数目
       patchLen...  %patch转为向量（按列连接成列向量）时的长度
       nnmConst... %WNNM计算权值用的常数
       eps...   %WNNM避免除以零而设定的常数
       noiseVar %AWGN方差,一开始取值[0, 255]便于找原图像，后来归一化到[0, 1]便于计算
   
image=im2double(imread('E:/Design/denoise/test_results/第1次.jpg'));   %读入图像，并从[0, 255]uint8转为[0, 1]double
noiseVar=50/255;
[rs, cs]=size(image);
prs=16;pcs=16;patchLen=prs*pcs; %滑动块大小
rstep=prs/2;cstep=pcs/2;    %为了加速，步进设置为半个块大小
patchNum=10;    
nnmConst=2.8;
eps=10e-16;

denoImage=SAIF(image);
imwrite(denoImage, ['E:/Design/denoise/test_results/第1次', 'SAIF', '.jpg']);