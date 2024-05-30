% INPUT:
% x = variable to create cumulative dist from
% 
% edges = Vector of bin edges to split data into when calculating
% cumulative dist. Range should include min and max of x and should be over
% sampled for a smooth curve.

% OUTPUT:
% Cumulative distribution of x defined by edges. Plot output to get
% cumulative distribution curve plot(pedges(1:end-1),yprob).

function [cumulativeDist] = cDist(x,edges)

% Finds the number of counts within each bin = n
[n] = histcounts(x,edges);

% Creates cumulative dist
for i=1:length(n);
    cumulativeDist(i) = sum(n(1:i))/length(x);
end

end