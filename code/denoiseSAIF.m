clear all
close all
global image... %ԭʼ����ͼ��
       rs cs... %ԭͼ�������������
       prs pcs...   %patch������������
       rstep cstep... %Ϊ�˼��٣������еĲ���
       patchNum...  %block match�������������Ŀ
       patchLen...  %patchתΪ�������������ӳ���������ʱ�ĳ���
       nnmConst... %WNNM����Ȩֵ�õĳ���
       eps...   %WNNM�����������趨�ĳ���
       noiseVar %AWGN����,һ��ʼȡֵ[0, 255]������ԭͼ�񣬺�����һ����[0, 1]���ڼ���
   
image=im2double(imread('E:/Design/denoise/test_results/��1��.jpg'));   %����ͼ�񣬲���[0, 255]uint8תΪ[0, 1]double
noiseVar=50/255;
[rs, cs]=size(image);
prs=16;pcs=16;patchLen=prs*pcs; %�������С
rstep=prs/2;cstep=pcs/2;    %Ϊ�˼��٣���������Ϊ������С
patchNum=10;    
nnmConst=2.8;
eps=10e-16;

denoImage=SAIF(image);
imwrite(denoImage, ['E:/Design/denoise/test_results/��1��', 'SAIF', '.jpg']);