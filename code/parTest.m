%poolobj=parpool('local', 2);
tic;
x=zeros(1e9, 1);
parfor i=1:1e9
    x(i)=i+1;
end
toc;
%delete(poolobj);

tic;
y=zeros(1e9, 1);
for i=1:1e9
    y(i)=i+1;
end
toc;

