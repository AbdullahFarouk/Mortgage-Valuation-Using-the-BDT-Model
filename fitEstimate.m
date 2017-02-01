% this function gives us he best parameter values (best fit) that minimize the errors
% associated with estimation
function output=fitEstimate(m,y)

error=@(param) sum((NS(m,param)-y).^2);

paramBest=fminsearch(error,[0,0,9,12])



output=@(m) NS(m,paramBest);
end

