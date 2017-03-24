function denoImage=adaBoost(tempImage)
    global image rs cs prs pcs patchNum patchLen c eps noiseVar
    denoImage=zeros(rs, cs);   %用于point-wise的估计
    numbers=zeros(rs, cs);  %用于计算每个坐标被访问了多少次
    for xpos=1:prs:rs-prs+1 %允许矩形的patch
        for ypos=1:pcs:cs-pcs+1
            [patches, dist]=blockMatch(tempImage, xpos, ypos);
            [U, S, V]=svd(patches);
            sigma=diag(S);  %污染patches的奇异值向量
            sigmaEst=sqrt(max(sigma.*sigma-patchNum*noiseVar, 0));  %估计干净patches的奇异值向量
            weight=c*sqrt(patchNum)./(sigmaEst+eps);
            SwDiag=max(sigma-weight, 0);
            Sw=zeros(patchLen, patchNum);
            len=length(SwDiag);
            for i=1:len
                Sw(i,i)=SwDiag(i);
            end
            %计算聚合的权值
            h=10;%使用exp(-d^2/h)计算权值,h是调节参数
            funcValues=exp(-(dist.*dist)/h);
            aggWeight=funcValues/sum(funcValues);
            aggWeights=repmat(aggWeight', patchLen, 1);
            denoPatch=sum((U*Sw*V').*aggWeights, 2);  %聚合(加权平均)
            %计算AdaBoost自适应的反馈系数
            primPatch=reshape(image(xpos:xpos+prs-1, ypos:ypos+pcs-1), patchLen, 1);    %列向量
            normXest=norm(denoPatch);
            EnResi=c*abs(noiseVar-var(primPatch-denoPatch));    %残余噪声能量
            rhoK=normXest/(normXest+sqrt(max(normXest*normXest-EnResi, 0)));   %自适应的反馈系数
            denoImage(xpos:xpos+prs-1, ypos:ypos+pcs-1)=denoImage(xpos:xpos+prs-1, ypos:ypos+pcs-1)+reshape(denoPatch+(1-rhoK)*(primPatch-denoPatch), prs, pcs);   %反馈
            numbers(xpos:xpos+prs-1, ypos:ypos+pcs-1)=numbers(xpos:xpos+prs-1, ypos:ypos+pcs-1)+ones(prs, pcs);
        end
    end
    denoImage=denoImage./numbers;   %此处采用简单平均
end
