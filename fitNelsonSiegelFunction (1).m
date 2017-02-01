function output=fitNelsonSiegelFunction(m,y)
%I tell MATLAB my function name is fitNelsonFunction and to store its value
%in output.

error=@(param) sum((NS(m,param)-y).^2);
%The error function will be a function of param and it will give me the SSR
%varying only the values of param vector.


paramBest=fminsearch(error,[0,0,9,12]);
%I ask MATLAB to give me the values of th eparam vector that minimize my
%SSR


%output=@(m) NS(m,paramBest);
output =paramBest;
%Here when I call the fitNelsonSiegelFunction, it will output a function
%with m as itsonly varying parameter. Hence when I specify my m, I should
%get my NS estimate.
end

