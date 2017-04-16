clear all
sigma=(1:3)';
k=(1:2)';
noiseVar=1;
b2=(1:3)';
temp1=arrayfun(@(k) sum((1-sigma.^k).^2.*b2+noiseVar*sigma.^(2*k)), k);