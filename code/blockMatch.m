function [patches, dist]=blockMatch(tempImage, xpos, ypos)
%说明：块匹配算法，使用矩阵的F范数寻找与给定block相似的块，全局搜索，以左上坐标为开始坐标,

global rs cs prs pcs rstep cstep patchNum patchLen
gblk=tempImage(xpos:xpos+prs-1, ypos:ypos+pcs-1);
rnum=(rs-prs)/rstep;cnum=(cs-pcs)/cstep;
distances=zeros(rnum*cnum, 1);  %所有sliding blocks与ref block的distance
for i=1:rnum
    for j=1:cnum
        rbegin=(i-1)*rstep+1;cbegin=(j-1)*cstep+1;
        blk=tempImage(rbegin:rbegin+prs-1,cbegin:cbegin+pcs-1);
        diff=double(blk)-double(gblk);
        distances((i-1)*cnum+j)=norm(diff, 'fro')/patchLen;  
    end
end

[distances, index]=sort(distances);

%只取distance最小的patchNum个块
dist=distances(1:patchNum);
matchInd=index(1:patchNum);

cth=mod(matchInd-1, cnum)+1 ; %以patch的size看，在多少列
rth=floor((matchInd-1)/cnum)+1; %以patch的size看，在多少行
matchX=1+rstep*(rth-1); %真实的起始行坐标
matchY=1+cstep*(cth-1); %真实的起始列坐标

patches=zeros(patchLen, patchNum);
for k=1:patchNum
    patches(:, k)=reshape(tempImage(matchX(k):matchX(k)+prs-1, matchY(k):matchY(k)+pcs-1), patchLen, 1);
end
end


