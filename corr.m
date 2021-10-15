function c = corr( data )
%c = corr( data )
%	Calculate all pairwise correlations among the columns of DATA.
%	This duplicates the function of the corr() function in the
%   Statistics toolbox and is only included because not every
%   machine I use has that toolbox installed.

    v = cov(data);
    s = diag(sqrt(1./diag(v)));
    c = s*v*s;
end
