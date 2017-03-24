function [patches, dist]=blockMatch(tempImage, xpos, ypos)
%ʹ�þ����F����Ѱ�������block���ƵĿ飬ȫ������������������Ϊ��ʼ����,
%x,ypos��������block��x��y���ꣻ
%patches:10��ƥ��飨��ԭͼ��飩��ɵľ���ÿ��patch����������Ϊpatches�����һ��
global rs cs prs pcs patchNum patchLen
gblk=tempImage(xpos:xpos+prs-1, ypos:ypos+pcs-1);
rbnd=(rs-prs+1);cbnd=(cs-pcs+1);
distances=zeros(rbnd*cbnd, 1);  %����sliding blocks��ref block��distance
for i=1:rbnd
    for j=1:cbnd
        blk=tempImage(i:i+prs-1,j:j+pcs-1);
        diff=double(blk)-double(gblk);
        distances((i-1)*cbnd+j)=norm(diff, 'fro')/patchLen;       
    end
end
[distances, index]=sort(distances);
dist=distances(1:patchNum);
matchInd=index(1:patchNum);
matchX=fix((matchInd-1)./cbnd)+1;
matchY=mod((matchInd-1), cbnd)+1;
patches=zeros(patchLen, patchNum);
for k=1:patchNum
    patches(:, k)=reshape(tempImage(matchX(k):matchX(k)+prs-1, matchY(k):matchY(k)+pcs-1), patchLen, 1);
end
end

