function denoImage=SAIF(basicImage)

global rs cs... %ԭͼ�������������
       prs pcs...   %patch������������
       rstep cstep... %Ϊ�˼��٣������еĲ���
       patchNum...  %block match�������������Ŀ
       patchLen...  %patchתΪ�������������ӳ���������ʱ�ĳ���
       nnmConst... %WNNM����Ȩֵ�õĳ���
       eps...   %WNNM�����������趨�ĳ���
       noiseVar %AWGN����,һ��ʼȡֵ[0, 255]������ԭͼ�񣬺�����һ����[0, 1]���ڼ���
   
   slidePatchNum=((rs-prs)/rstep+1)*((cs-pcs)/cstep+1); %�����������Ŀ
   sNum=slidePatchNum*patchLen; %���ڹ���ϡ�����������Ĵ�С
   %��Ϊ������
   rAixs=zeros(1, sNum);    %������
   cAixs=zeros(1, sNum);    %������
   sValue=zeros(1, sNum);   %�Ҷ�ֵ
   sRisk=zeros(1, sNum);    %risk
   d3=1;    %��¼�������ڶ��ٸ�������
 for rpos=1:rstep:rs-prs+1 
    for cpos=1:cstep:cs-pcs+1
        
        %����filter W=U*Sw*U'
        [patches, ~]=blockMatch(basicImage, rpos, cpos);    %��ƥ��
        y=patches(:, 1);    %��������patch��������������
        [U, S, ~]=svd(patches);
        b=U'*y; %����ο�����U�ӿռ��µ�����
        sigma=diag(S);  %��Ⱦpatches������ֵ����
        sigmaEst=sqrt(max(sigma.*sigma-patchNum*noiseVar, 0));  %���Ƹɾ�patches������ֵ����
        weight=nnmConst*sqrt(patchNum)./(sigmaEst+eps);
        SwDiag=max(1-weight./sigma, 0);
        Sw=diag([SwDiag; zeros(patchLen-patchNum, 1)]); %����SwӦ����S��С��ͬ����������Ҫ��Sw�ǶԽ�����˲��䲻�������ֵ
        filter=U*Sw*U';
        clear patches S sigmaEst weight  
        
        %������diffusion����boosting����������ѵ�������
        k=1:10;  %������Ҫ�� k=argmin Risk, ��������̫���ӣ�һ����˵��������������̫�������ݶ����10�Σ��Խ�ʡ������
        b2=b.*b;    %���ڼ������ʱ����
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
        
        %ȥ��
        denoPatch=transpose(oper*y);    %ת��Ϊ������
        bpos=(d3-1)*patchLen+1;epos=d3*patchLen;
        d3=d3+1;
        rAixs(bpos:epos)=repmat(rpos:rpos+prs-1, 1, pcs);
        cAixs(bpos:epos)=reshape(repmat(cpos:cpos+pcs-1, prs, 1), 1, patchLen);
        sValue(bpos:epos)=denoPatch;
        sRisk(bpos:epos)=exp(-risk)*ones(1, patchLen);
    end
 end
 
 %תΪϡ����󣬲��ͷſռ�
 spixelValue=sparse(rAixs, cAixs, sValue, rs*cs, slidePatchNum);
 spixelRisk=sparse(rAixs, cAixs, sRisk, rs*cs, slidePatchNum);
 clear rAixs cAixs sValue sRisk
 
 %��Ȩ�ۺϣ�תΪ[0, 255], ת����������
 denoImage=full(im2uint8(bsxfun(@rdivide, spixelValue.*spixelRisk, sum(spixelRisk, 2))));
end
 
 
 
        
        
        
        
        
        
        
        
        
        
        
        
        
       
        
