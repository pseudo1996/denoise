function denoImage=wnnm(image)
    global rs cs brs bcs patchNum c eps noiseVar patchLen
    for xpos=1:brs:rs-brs+1 %允许矩形的patch
        for ypos=1:bcs:cs-bcs+1
            patches=blockMatch(image, xpos, ypos);
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
            denoPatches=U*Sw*V';
            denoPatch=reshape(mean(denoPatches, 2), brs, bcs);  %聚合，列向量变成矩阵 
            test=norm(denoPatch-image(xpos:xpos+brs-1, ypos:ypos+bcs-1), 2);
            denoImage(xpos:xpos+brs-1, ypos:ypos+bcs-1)=denoPatch;
        end
    end
end