function crho = corrRho( x, y )
%ctau = corrTau( x, y )
%   Calculate Spearman's rho correlation between x and y.

    n = length(x);
    [sx,px] = sort(x);
    rankx(px) = 1:n;
    [sy,py] = sort(y);
    ranky(py) = 1:n;
    %crho = corr( [rankx', ranky'] );
    %crho = crho(1,2);
    crho = 1 - 6*sum( (rankx-ranky).^2 )/(n*(n*n-1))
    % plot(rankx,ranky,'.');
end
