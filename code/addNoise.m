lena=im2double(imread('E:/±œ…Ë/code/lena/lena.bmp'));
s=rng;
for sigma=10:10:100
    noiseLena=lena+(sigma/255)*randn(size(lena));
    imwrite(noiseLena, [num2str(sigma), '.jpg']);
end
rng(s);

    




