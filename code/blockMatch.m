function [patches, dist]=blockMatch(tempImage, xpos, ypos)
%块匹配算法，使用矩阵的F范数寻找与给定block相似的块，全局搜索，以左上坐标为开始坐标

global rs cs prs pcs rstep cstep patchNum patchLen
gblk=tempImage(xpos:xpos+prs-1, ypos:ypos+pcs-1);   %参考图像块
rnum=(rs-prs)/rstep;cnum=(cs-pcs)/cstep;    %行与列上的块数目
distances=zeros(rnum*cnum, 1);  %所有滑动块与参考块的距离
for i=1:rnum
    for j=1:cnum
        rbegin=(i-1)*rstep+1;cbegin=(j-1)*cstep+1;  %滑动块的左上角坐标
        blk=tempImage(rbegin:rbegin+prs-1,cbegin:cbegin+pcs-1);
        diff=double(blk)-double(gblk);  %是一开始就把图像转为[0, 1]double好，还是需要时转换好？（针对运行速度而言）
        distances((i-1)*cnum+j)=norm(diff, 'fro')/patchLen;  
    end
end

[distances, index]=sort(distances);

%只取distance最小的patchNum个块
dist=distances(1:patchNum);
matchInd=index(1:patchNum);

clear distances index   %释放无用变量所占内存

cth=mod(matchInd-1, cnum)+1 ; %以patch的size看，在多少列
rth=floor((matchInd-1)/cnum)+1; %以patch的size看，在多少行
matchX=1+rstep*(rth-1); %真实的起始行坐标
matchY=1+cstep*(cth-1); %真实的起始列坐标

patches=zeros(patchLen, patchNum);
%根据坐标获得块，并按列连接成列向量，组成矩阵
for k=1:patchNum
    patches(:, k)=reshape(tempImage(matchX(k):matchX(k)+prs-1, matchY(k):matchY(k)+pcs-1), patchLen, 1);    
end
end


