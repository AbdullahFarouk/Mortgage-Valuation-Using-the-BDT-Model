function output = mortgage(principle,mortgageRate,n,frequency,shortTree,refinance,k)

%Refinance = 1 if refinancing is allowed, 0 otherwise- boolean variable
%n : number years to maturity
%frequency number of compounding periods per year 
%k is the refinancing cost

r=mortgageRate/frequency;
T=n*frequency;

dt=1/frequency;

thisTree=NaN(T+1,T+1);



%Calculate fixed payment amount;
c=principle*r/(1-1/(1+r)^T);
%We back out the fixed payment to be made by using the annuity formula.

%Last payment, at maturity
thisTree(T+1,:)=c;


if refinance==1
    
    for i = T:-1:1
        for j = 1:i;
                %calculate
                
                thisR=shortTree(i,j);
                continuationValue=.5*(thisTree(i+1,j)+thisTree(i+1,j+1))*exp(-thisR*dt);
                outstandingBalance=c/r*(1-1/(1+r)^(T+1-i))*(1+k);
                
                thisTree(i,j)=c+min(outstandingBalance,continuationValue);
                
        end
    end
else

    %No refinancing allowed
        
        for i = T:-1:1
               for j = 1:i;
                   %Calculate 
                   
                   thisR=shortTree(i,j);
                   continuationValue=.5*(thisTree(i+1,j)+thisTree(i+1,j+1))*exp(-thisR*dt);
                   
                   thisTree(i,j)=c+continuationValue;
                   
               end
        end
end
                            
%Remove extra payment at the beggining 
output=thisTree(1,1)-c;

end

