function estimateCorrDist( cohsteps, cohcycles, N )
%estimateCorrDist( cohsteps, cohcycles, N )
%   Estimate the distribution of the correlation coefficient for two
%   independently generated slowly varying waveforms, and for two
%   independently generated sequences of independent variables.
%
%   In both cases the expectation value of the correlation is zero, but the
%   spread of values is much larger for the slowly varying waveforms,
%   reflecting the fact that the effective number of degrees of freedom is
%   far less than the number of samples.

    totalsteps = cohsteps*cohcycles;
    fprintf( 1, 'cohsteps %d, cohcycles %d, totalsteps %d, N %d\n', ...
        cohsteps, cohcycles, totalsteps, N );
    c = zeros( N, 1 );
    for i=1:N
        D0 = rand_bac( cohsteps, totalsteps );
        D0 = startatzero( D0 );
        D1 = rand_bac( cohsteps, totalsteps );
        D1 = startatzero( D1 );
        corrmx = corr( [D0, D1] );
        c(i) = corrmx(1,2);
        if mod(i,50)==0
            fprintf( 1, '%s: iteration %d of %d\n', mfilename(), i, N );
        end
    end
    figure(1);
    hist(c);
    s1 = std(c);
    c = zeros( N, 1 );
    for i=1:N
        D = randn(totalsteps,2);
        corrmx = corr( D );
        c(i) = corrmx(1,2);
    end
    figure(2);
    hist(c);
    s2 = std(c);
    sr = s1/s2;
    vr = sr^2;
    vrr = vr/cohsteps;
    fprintf( 1, 'Std. dev of correlation\n' );
    fprintf( 1, 'White noise: c_wn = %8.3f\n', s2 );
    fprintf( 1, 'Slow random: c_sr = %8.3f\n', s1 );
    fprintf( 1, 'Ratio of std. devs.: sd_ratio = %8.3f\n', sr );
    fprintf( 1, 'Ratio of variances: v_ratio = %8.3f\n', vr );
    fprintf( 1, 'v_ratio/coherencesteps: %8.3f\n', vrr );
    
end

