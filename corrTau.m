function ctau = corrTau( x, y )
%ctau = corrTau( x, y )
%   Calculate Kendall's tau correlation between x and y.

    n = length(x);
    [sx,px] = sort(x);
    rankx(px) = 1:n;
    [sy,py] = sort(y);
    ranky(py) = 1:n;
    xlty = repmat( x, n, 1 ) < repmat( y', 1, n );
    rxlty = repmat( rankx, n, 1 ) < repmat( ranky', 1, n );
    concord = (sum( xlty(:) == rxlty(:) ) - n)/2;
    % discord = n*(n-1)/2 - concord;
    ctau = 4*concord/(n*(n-1)) - 1;
end
