clear all
close all
global image... %原始图像
       rs cs... %原图像的行数与列数
       prs pcs...   %patch的行数与列数
       patchNum...  %block match中允许的最大数目
       patchLen...  %patch转为向量时的长度
       c... %AdaBoost计算残余噪声能量时用到的常数
       eps...   %WNNM避免除以零而设定的常数
       noiseVar %AWGN方差
noiseVar=50;
rawImage=imread(['E:/毕设/code/lena/', num2str(noiseVar), '.jpg']);   %rawImage像素类型为uint8
image=double(rawImage); %为便于像素运算，将uint8转为double类型
[rs, cs]=size(image);
prs=8;pcs=8;patchLen=prs*pcs;
patchNum=10;
c=1;
eps=10e-16;
K=1;   %迭代处理次数
denoImage=image;    %最终得到的去噪图像
tstart=tic;
for k=1:K
   denoImage=adaBoost(denoImage);
end
tend=toc(tic);
denoImage=uint8(round(denoImage));  %将像素类型转为uint8，便于显示
imwrite(denoImage, ['AB&', num2str(prs), '&', num2str(K), '&', num2str(round(tend)), '.jpg']);