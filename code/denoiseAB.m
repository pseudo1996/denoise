clear all
close all
global image... %原始含噪图像
       rs cs... %原图像的行数与列数
       prs pcs...   %patch的行数与列数
       rstep cstep... %为了加速，行与列的步进
       patchNum...  %block match中允许的最大数目
       patchLen...  %patch转为向量（按列连接成列向量）时的长度
       nnmConst... %WNNM计算权值用的常数
       adaConst... %AdaBoost计算残余噪声能量时用到的常数
       eps...   %WNNM避免除以零而设定的常数
       noiseVar %AWGN方差
noiseVar=50;
rawImage=imread(['E:/Design/denoise/test_pics', num2str(noiseVar), '.jpg']);   %rawImage像素类型为uint8
image=double(rawImage); %为便于像素运算，将uint8转为double类型
[rs, cs]=size(image);
prs=32;pcs=32;patchLen=prs*pcs; %处理块大小32*32
rstep=prs/2;cstep=pcs/2;
patchNum=10;    
nnmConst=2.8;
adaConst=1;
eps=10e-16;
K=1;   %迭代处理次数
denoImage=image;    %最终得到的去噪图像
tstart=tic; %计时开始
for k=1:K
   denoImage=adaBoost(denoImage);
end
tend=toc(tic);
denoImage=uint8(round(denoImage));  %将像素类型转为uint8，便于显示
imwrite(denoImage, ['AB&', num2str(prs), '&', num2str(K), '&', num2str(round(tend/60)), 'min','.jpg']); %保存结果，格式：算法&处理块大小&迭代次数&处理时间