%% Course: Quantitative Methods in Finance
% Project: Assignment 3 - Black, Derman and Toy Trees 
% Purpose:
%   Calculates the 30 year callable mortgage loan value under the presence
%   of refinancing risk
%   
% Outputs:
%               Graph which shows the movements and comparisons of
%               costless, costly and no refinancing risks on the mortgage
%               value of the loan.
%
% Files Used:
%               yieldData.csv  (from mycourses)
%               volatilityData.csv (from mycourses)
%
% Inputs, Parameters and Variables: 

%import data
clear all

% Set parameters

%End date, in years
T=30;
%number of periods per year
frequency =12;
%number of steps in the binomial tree
%N=3
N=frequency*T;
%Create vector of maturities, bond prices, and volatilities from nelson...
%Siegel

%set time step size 
dt=T/N;

%m for vector of maturities
m=(dt:dt:T)';

observedData = dataset(m);
%% excel replication
%%comented out sections bellow to replicating excel results heres
%price=[0.9091,.8116,.7118]';
%observedData.yield=price.^(-1./m)-1;
%observedData.volatility=[.01,.19,.18]';

%% test data

% import data from csv files 
yieldData=dataset('File','yieldData.csv','Delimiter',',');
%Create a yield dataset

parameters=fitNelsonSiegelFunction(yieldData.m,yieldData.y/100);
%I store the function that fitnelsonsiegel outputs in the variable yield,
%where the arguements it takes are maturity and yields from the yieldData
%dataset.


observedData.yield=NS(m,parameters);
%I create a dataset and stores the fitted values for yileds and
%volatilities from nelson siegel.

observedData.yield=observedData.yield;

observedData.yield=max(0,observedData.yield);
%get rid of negative yields


%%Create datasets, variables

observedData.price=(1+observedData.yield).^(-m);
%I calculate the price of a bond for a given maturity using the yield from
%the NelsonSiegel function
%observedData.price=observedData.yield)*exp(-m);

%Add observed (fitted)volatilities
volatilityData= dataset('File','volatilityData.csv','Delimiter',',');
volatilityParam=fitNelsonSiegelFunction(volatilityData.m,volatilityData.vol/100);
volatility=@(m) NS(m,volatilityParam);
%I store the function that fitnelsonsiegel outputs in the variable volatility,
%where the arguements it takes are maturity and volatility from the yieldData
%dataset.
 
observedData.volatility=volatility(observedData.m);

%the first volatility is always 0, no matter what nelson siegel says

observedData.volatility(1)=0;

%Use continuous rates/discounting 

%Create empty tree. the (i,j) node represents time i and node j of the
%short rate tree

shortTree=NaN(N,N);


%Starting Guesses for fminsearch
startR=.01;
startParam=[.001,.01];

%% Create first node in tree
i=1;
thisPrice=observedData.price(i);
thisMaturity=observedData.m(i);
%No volatility matching for first node
thisR=-(1/dt)*log(thisPrice);
shortTree(i,1)=thisR;
%%Moving on i the tree

%Get access to the thisTree from bondTree()
global thisTree;

% we create a for loop to populate the short tree for each node
for i=2:N
    i/N
    % we set the parameters for price, maturity and volatility from the
    % dataset
    thisPrice=observedData.price(i);
    thisMaturity=observedData.m(i);
    thisVolatility=observedData.volatility(i);
    
    thisPriceAndVol=[thisPrice,thisVolatility];
    
    %No volatility matching for first node
    %abs() added to constrain param to be positive
    thisError=@(param) sum((thisPriceAndVol-bondTree(abs(param),i,dt,shortTree)).^2);
    thisParam=abs(fminsearch(thisError,startParam));
    
    %Build next step in tree with the right parameters
    thisBottomR=thisParam(1);
    thisSigma=thisParam(2);
    
    treeStep=exp(2*thisSigma*sqrt(dt));
    
    %populate next step in shortTree
    shortTree(i,1)=thisBottomR;
    for j=2:(i)
        shortTree(i,j)=shortTree(i,j-1)*treeStep;
    end
    
end

% Calculate Mortgage Values based on required parameters
principle=1000;
mortgageRate=.02;
n=30;
frequency=12;
refinance=1;
k=0;

% call the functions to get the mortgage values with refinancing done
mortgageValueWithRefinancing=mortgage(principle,mortgageRate,n,frequency,shortTree,refinance,k)

% Find mortgage rates (functions called)
error=@(mortgageRate)(mortgage(principle,mortgageRate,n,frequency,shortTree,refinance,k)-principle)^2;
mortgageRateWithRefinancing=fminsearch(error,.02);

% setting refinancing to zero to get mortgage values without any
% refinancing
refinance==0;

% we calculate the mortgage values for no refinancing allowed
mortgageValueOutRefinancing=mortgage(principle,mortgageRate,n,frequency,shortTree,refinance,k)

% we calculate the mortgage rates for no refinancing allowed
error=@(mortgageRate)(mortgage(principle,mortgageRate,n,frequency,shortTree,refinance,k)-principle)^2;
mortgageRateWithOutRefinancing=fminsearch(error,.02);


% we now change the values of k to see what happens when k increases to 0
% to 10 percent. This will help us analyze the impact of k on mortgage
% value

% With Refinancing cost k equal to 1 percent

k=.01

% this gives us the mortgage cost for k equal to 1 percent
mortgageValueWithCostlyRefinancing=mortgage(principle,mortgageRate,n,frequency,shortTree,refinance,k)

% we find mortgage rates based on k equal to 1 percent
error=@(mortgageRate)(mortgage(principle,mortgageRate,n,frequency,shortTree,refinance,k)-principle)^2;
mortgageRateWithCostlyRefinancing=fminsearch(error,.02);



% for k equal to 5 percent, we plot graphs to compare the mortgage values
% for three scenarios: First with no refinancing done, second with costless
% refinancing done and the third with costly refinancing with a 5 percent
% cost of refinancing taken
k=0.05
% we use the appropriate continuous discount rate 
rates=.027:.00001:.034;
% we store the rates in the plot mortgage function so we can graph it later
plotMortgage=dataset(rates');

% we create a for loop to store all the mortgage values for no refinancing,
% refinancing and costly refinancing. We need to plot these on graphs
% for each value of i
for i=1:size(plotMortgage,1)
    i
    plotMortgage.noRefinancing(i)=mortgage(principle,rates(i),n,frequency,shortTree,0,k);
    plotMortgage.refinancing(i)=mortgage(principle,rates(i),n,frequency,shortTree,refinance,0);
plotMortgage.costlyRefinancing(i)=mortgage(principle,rates(i),n,frequency,shortTree,refinance,k);
end

% we generate the graphs here to compare the no refinancing, costless
% refinancing and costly refinancing mortgage values 
subplot(2,1,1);
title('Value of Mortgage at Different Mortagage Rates')
% we plot in the x,y format. The y axis values represent the mortgage
% values while the x axis values represent the mortgage rates
plot( plotMortgage.Var1,plotMortgage.noRefinancing,...
    plotMortgage.Var1,plotMortgage.costlyRefinancing,plotMortgage.Var1,plotMortgage.refinancing)

% defining the labels of the graph
legend('No Refinancing','Costly Refinancing k=.05','Freee Refinancing','Location','northwest')


% we define the index to get a zoom in of the graph so we can look at the
% differences in greater detail
index=1:size(rates');

startIndex=index(rates==.02899)
endIndex=index(rates==.02901)
plotRange=startIndex:endIndex
subplot(2,1,2);

% we again plot the graph with same labels but different index to get a
% more elaborate difference between costless and costly refinancing lines 
plot(plotMortgage.Var1(plotRange),plotMortgage.noRefinancing(plotRange),...
    plotMortgage.Var1(plotRange),plotMortgage.costlyRefinancing(plotRange),plotMortgage.Var1(plotRange),plotMortgage.refinancing(plotRange))

% defining the legend for the graph
legend('No Refinancing','Costly Refinancing k=0.05','Free Refinancing','Location','Southeast');
