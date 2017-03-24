function denoImage=adaBoost(tempImage)
    global image rs cs prs pcs patchNum patchLen c eps noiseVar
    denoImage=zeros(rs, cs);   %����point-wise�Ĺ���
    numbers=zeros(rs, cs);  %���ڼ���ÿ�����걻�����˶��ٴ�
    for xpos=1:prs:rs-prs+1 %�������ε�patch
        for ypos=1:pcs:cs-pcs+1
            [patches, dist]=blockMatch(tempImage, xpos, ypos);
            [U, S, V]=svd(patches);
            sigma=diag(S);  %��Ⱦpatches������ֵ����
            sigmaEst=sqrt(max(sigma.*sigma-patchNum*noiseVar, 0));  %���Ƹɾ�patches������ֵ����
            weight=c*sqrt(patchNum)./(sigmaEst+eps);
            SwDiag=max(sigma-weight, 0);
            Sw=zeros(patchLen, patchNum);
            len=length(SwDiag);
            for i=1:len
                Sw(i,i)=SwDiag(i);
            end
            %����ۺϵ�Ȩֵ
            h=10;%ʹ��exp(-d^2/h)����Ȩֵ,h�ǵ��ڲ���
            funcValues=exp(-(dist.*dist)/h);
            aggWeight=funcValues/sum(funcValues);
            aggWeights=repmat(aggWeight', patchLen, 1);
            denoPatch=sum((U*Sw*V').*aggWeights, 2);  %�ۺ�(��Ȩƽ��)
            %����AdaBoost����Ӧ�ķ���ϵ��
            primPatch=reshape(image(xpos:xpos+prs-1, ypos:ypos+pcs-1), patchLen, 1);    %������
            normXest=norm(denoPatch);
            EnResi=c*abs(noiseVar-var(primPatch-denoPatch));    %������������
            rhoK=normXest/(normXest+sqrt(max(normXest*normXest-EnResi, 0)));   %����Ӧ�ķ���ϵ��
            denoImage(xpos:xpos+prs-1, ypos:ypos+pcs-1)=denoImage(xpos:xpos+prs-1, ypos:ypos+pcs-1)+reshape(denoPatch+(1-rhoK)*(primPatch-denoPatch), prs, pcs);   %����
            numbers(xpos:xpos+prs-1, ypos:ypos+pcs-1)=numbers(xpos:xpos+prs-1, ypos:ypos+pcs-1)+ones(prs, pcs);
        end
    end
    denoImage=denoImage./numbers;   %�˴����ü�ƽ��
end