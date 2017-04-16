function denoImage=SAIF(basicImage)

global rs cs... %原图像的行数与列数
       prs pcs...   %patch的行数与列数
       rstep cstep... %为了加速，行与列的步进
       patchNum...  %block match中允许的最大数目
       patchLen...  %patch转为向量（按列连接成列向量）时的长度
       nnmConst... %WNNM计算权值用的常数
       eps...   %WNNM避免除以零而设定的常数
       noiseVar %AWGN方差,一开始取值[0, 255]便于找原图像，后来归一化到[0, 1]便于计算
   
   slidePatchNum=((rs-prs)/rstep+1)*((cs-pcs)/cstep+1); %滑动块的总数目
   sNum=slidePatchNum*patchLen; %用于构建稀疏矩阵的向量的大小
   %均为行向量
   rAixs=zeros(1, sNum);    %行坐标
   cAixs=zeros(1, sNum);    %列坐标
   sValue=zeros(1, sNum);   %灰度值
   sRisk=zeros(1, sNum);    %risk
   d3=1;    %记录处理到第多少个滑动块
 for rpos=1:rstep:rs-prs+1 
    for cpos=1:cstep:cs-pcs+1
        
        %计算filter W=U*Sw*U'
        [patches, ~]=blockMatch(basicImage, rpos, cpos);    %块匹配
        y=patches(:, 1);    %待处理的patch，已拉成列向量
        [U, S, ~]=svd(patches);
        b=U'*y; %计算参考块在U子空间下的坐标
        sigma=diag(S);  %污染patches的奇异值向量
        sigmaEst=sqrt(max(sigma.*sigma-patchNum*noiseVar, 0));  %估计干净patches的奇异值向量
        weight=nnmConst*sqrt(patchNum)./(sigmaEst+eps);
        SwDiag=max(1-weight./sigma, 0);
        Sw=diag([SwDiag; zeros(patchLen-patchNum, 1)]); %本来Sw应该与S大小相同，但论文上要求Sw是对角阵，因此补充不足的奇异值
        filter=U*Sw*U';
        clear patches S sigmaEst weight  
        
        %计算是diffusion还是boosting，并计算最佳迭代次数
        k=1:10;  %论文上要求 k=argmin Risk, 但是这样太复杂，一般来说迭代次数不可能太大，所以暂定最大10次，以节省运算量
        b2=b.*b;    %便于计算的临时变量
        dRiskK=arrayfun(@(k) sum((1-sigma.^k).^2.*b2+noiseVar*sigma.^(2*k)), k);
        bRiskK=arrayfun(@(k) sum((1-sigma).^(2*k+2).*b2+noiseVar*(1-(1-sigma).^(k+1)).^2), k);
        [dRisk, di]=min(dRiskK);
        [bRisk, bi]=min(bRiskK);
        if dRisk>bRisk
            risk=bRisk;
            iterNum=bi;
            oper=eye(patchLen)-(eye(patchLen)-filter)^(iterNum+1);
        else
            risk=dRisk;
            iterNum=di;
            oper=filter^iterNum;
        end
        
        %去噪
        denoPatch=transpose(oper*y);    %转置为行向量
        bpos=(d3-1)*patchLen+1;epos=d3*patchLen;
        d3=d3+1;
        rAixs(bpos:epos)=repmat(rpos:rpos+prs-1, 1, pcs);
        cAixs(bpos:epos)=reshape(repmat(cpos:cpos+pcs-1, prs, 1), 1, patchLen);
        sValue(bpos:epos)=denoPatch;
        sRisk(bpos:epos)=exp(-risk)*ones(1, patchLen);
    end
 end
 
 %转为稀疏矩阵，并释放空间
 spixelValue=sparse(rAixs, cAixs, sValue, rs*cs, slidePatchNum);
 spixelRisk=sparse(rAixs, cAixs, sRisk, rs*cs, slidePatchNum);
 clear rAixs cAixs sValue sRisk
 
 %加权聚合，转为[0, 255], 转回完整矩阵
 denoImage=full(im2uint8(bsxfun(@rdivide, spixelValue.*spixelRisk, sum(spixelRisk, 2))));
end
 
 
 
        
        
        
        
        
        
        
        
        
        
        
        
        
       
        

