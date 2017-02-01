function yNS=NS(m,param)
%NS tells matlab that the NS function that takes the
%arguments param and m. The output of this function should be stored in
%the variable yNS.

beta0=param(1);
beta1=param(2);
beta2=param(3);
tau=param(4);
% I specify the components of my param vector

yNS=beta0+beta1*((1-exp(-m/tau))./(m/tau))+beta2*(((1-exp(-m/tau))./(m/tau))-exp(-m/tau));
%Here I tell MATLAB what it should output when I call the NS function. I
%use the ./ to tell matlab that maturity is a vector and therefore when i
%divide by a vector I must spcify that MATLAB does it on an element-wise
%basis.

end

