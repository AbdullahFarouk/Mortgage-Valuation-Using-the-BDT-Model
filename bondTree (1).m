function output= bondTree(param,globali,dt,shortTree)

%output is a vector containing 1)price and 2)volatility from the bdt bond
%tree

%param is a vector containing 1)a guess for the lowest possible short rate
%bottom R and 2) a guess for the short rate volatility sigma

%shortTree is the fullsized BDT tree (possibly still partially empty)
thisShortTree=shortTree;

%hardcode globall=2

thisMaturity=globali*dt;

%The i-th bond tree is i+1 by j+1
thisTree=NaN(globali+1,globali+1);

%terminal pay off is always $1

thisTree(globali+1,:)=1;

bottomR=param(1);
sigma=param(2);

treeStep=exp(2*sigma*sqrt(dt));

%populate next step in shortTree
thisShortTree(globali,1)=bottomR;

for j=2:(globali)
    thisShortTree(globali,j)=thisShortTree(globali,j-1)*treeStep;
end

%claculate bond price from the back
for i = globali:-1:1;
    for j = 1:i;
        %calculate
        
        thisR=thisShortTree(i,j);
        
        thisTree(i,j)=.5*(thisTree(i+1,j)+thisTree(i+1,j+1))*exp(-thisR*dt);
    end
end

% set the price at node (1,1)
thisPrice=thisTree(1,1);

% set forward price at nodes ahead
nextPrice=thisTree(2,1:2);

% calculate forwad yield
nextYield=-1/(thisMaturity-dt)*log(nextPrice);

% calculate volatility based on forward and current yield
thisVolatility=log(nextYield(2)/nextYield(1))/2/sqrt(dt);

output=[thisPrice,thisVolatility];
end

%end


