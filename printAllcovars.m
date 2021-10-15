function printAllcovars( fid, data, labels, fuzz )
%printAllcovars( fid, data, labels, fuzz )
%   DATA is an N*K matrix of N observations on K variables.
%   LABELS is a cell array of K strings, the names of the variables.
%   This prints the conditional correlation and covariance of any two
%   variables, given any subset of the remainder held constant.  The
%   calculation assumes that the conditional covariance is independent of
%   the values of the variables conditioned on.  This is true for all
%   linear transformations of spherically symmetric distributions, a class
%   which includes the multivariate Gaussian.
%
%   For clarity, the correlations are printed twice, first as a rounded
%   value, then a value exact to three decimal places.
%
%   The rightmost column of numbers is log2( (1+c)/(1-c) ), c being the
%   correlation.  For values of c very close to +/- 1, this gives a clearer
%   idea of its value.  Roughly, it says how many bits of information
%   knowing one variable gives you about the other.  In general, values
%   above 30 result from the variables being mathematically identical,
%   differing only in rounding error.  The highest correlations between
%   mathematically distinct quantities amount to about 10 bits.
%
%   The FUZZ argument specifies how much independent random noise to add to
%   each element of DATA before processing.  Adding this noise ensures that
%   the correlations are well-defined even in cases where the relevant
%   part of the covariance matrix would otherwise be singular.
%   Obstructions to the computation due to singularity appear in the output
%   as NaN values.

    if nargin < 4
        fid = 1;
    end
    if nargin < 3
        fuzz = 0;
    end
    if fuzz == 0
        V = cov(data);
    else
        V = cov(data + randn(size(data))*fuzz);
    end
    numvars = size(data,2);
    numothers = numvars-2;
    fprintf( fid, 'All conditional correlations and covariances\n\n' );
    firstColWidth = 15;
    fprintf( fid, '%*s %7s %7s %7s %s\n', ...
        firstColWidth, '', 'Corr', 'Corr', 'Covar', 'log2( (1+c)/(1-c) )' );
    for i=1:(numvars-1)
        for j=(i+1):numvars
            fprintf( fid, '\n' );
            d = V(i,i) * V(j,j);
            if d <= 0
                c = NaN;
            else
                c = V(i,j)/sqrt(d);
            end
            s = [ labels{i}, ',' labels{j} ];
            fprintf( fid, '%s%*s %7s %7.3f %7.3f %7.3f\n', ...
                s, firstColWidth-length(s), '', ...
                roundc(c), c, V(i,j), log2(1+c)-log2(1-c) );
            for k=1:(2^numothers-1)
                % Create a bitmap of a non-empty subset of variables not
                % including i or j.
                kb = dec2bin( k );
                kb = [ false( 1, numothers - length(kb) ), kb == '1' ];
                kb = kb(end:-1:1);
                kb = [kb(1:i-1), false, kb(i:j-2), false, kb(j-1:end)];
                % Conditionalise on those variables.
                Vxx = conditionalCov( V, kb );
                % Extract the conditional covariance of i and j.
                i1 = sum( 1 - kb(1:i-1) ) + 1;
                j1 = i1 + sum( 1 - kb(i+1:j-1) ) + 1;
                Vi1j1 = Vxx( i1, j1 );
                d = Vxx(i1,i1) * Vxx(j1,j1);
                % The NaN cases are where the variances of i and j
                % are too small for the calculation to be meaningful.
                if d <= 0
                    Ci1j1 = NaN;
                else
                    Ci1j1 = Vi1j1/sqrt(d);
                    if abs(Ci1j1) > 1.001  % Allow for rounding error.
                        Ci1j1 = NaN;
                    elseif abs(Ci1j1) > 1
                        Ci1j1 = 1;
                    end
                end
                s = [ labels{i}, ',', labels{j}, '|', joinstrings( '', labels(kb==1) ) ];
                fprintf( fid, '%s%*s %7s %7.3f %7.3f %7.3f\n', ...
                    s, firstColWidth-length(s), '', ...
                    roundc(Ci1j1), Ci1j1, Vi1j1, log2(1+Ci1j1)-log2(1-Ci1j1) );
            end
        end
    end

    fprintf( fid, '\n' );
end

function s = roundc( c )
    if abs(c) < 0.1
        s = '0';
    elseif c > 0.9
        s = '1';
    elseif c < -0.9
        s = '-1';
    else
        s = sprintf( '%.1f', c );
    end
end

function Vxx1 = conditionalCov( V, vars )
% Obtain the covariance matrix conditional on some subset of the variables
% (those for which vars==1).
% A simple formula is Q = inv(V); Vxx1 = Q(vars,vars).  However, this fails
% whenever V is singular.  The calculation here fails only when
% V(vars,vars) is singular.
    Vxx = V( ~vars, ~vars );
    Vxy = V( ~vars, vars );
    Vyy = V( vars, vars );
    if cond(Vyy) > 1e10
        Vxx1 = NaN( size(Vxx) );
    else
        Vxx1 = Vxx - (Vxy/Vyy)*Vxy';
    end
end

function js = joinstrings( s, ss )
%js = joinstrings( s, ss )
%   ss is a cell array of strings.  Concatenate all members of ss together,
%   separated by the string s.

    if isempty(ss)
        js = '';
        return;
    end
    totlen = 0;
    for i=1:length(ss)
        totlen = totlen + length(ss{i});
    end
    totlen = totlen + length(s) * (length(ss)-1);
    js = char( zeros( 1, totlen ) );
    a = 1;
    b = length(ss{1});
    js(a:b) = ss{1};
    for i=2:length(ss)
        a = b+1;
        b = a+length(s)-1;
        js(a:b) = s;
        a = b+1;
        b = a+length(ss{i})-1;
        js(a:b) = ss{i};
    end
end