clear all
close all
global image... %ԭʼͼ��
       rs cs... %ԭͼ�������������
       prs pcs...   %patch������������
       patchNum...  %block match�������������Ŀ
       patchLen...  %patchתΪ����ʱ�ĳ���
       c... %AdaBoost���������������ʱ�õ��ĳ���
       eps...   %WNNM�����������趨�ĳ���
       noiseVar %AWGN����
noiseVar=50;
rawImage=imread(['E:/����/code/lena/', num2str(noiseVar), '.jpg']);   %rawImage��������Ϊuint8
image=double(rawImage); %Ϊ�����������㣬��uint8תΪdouble����
[rs, cs]=size(image);
prs=8;pcs=8;patchLen=prs*pcs;
patchNum=10;
c=1;
eps=10e-16;
K=1;   %������������
denoImage=image;    %���յõ���ȥ��ͼ��
tstart=tic;
for k=1:K
   denoImage=adaBoost(denoImage);
end
tend=toc(tic);
denoImage=uint8(round(denoImage));  %����������תΪuint8��������ʾ
imwrite(denoImage, ['AB&', num2str(prs), '&', num2str(K), '&', num2str(round(tend)), '.jpg']);