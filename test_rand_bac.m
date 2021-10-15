function test_rand_bac( coherencesteps, totalsteps )
%test_rand_bac( coherencesteps, totalsteps )
%   Test of rand_bac (random numbers with bounded autocorrelation).
%
%   This generates a random sequence by calling rand_bac( coherencesteps, totalsteps ).
%   It plots the first 10*coherencesteps values, and calculates and plots
%   the autocorrelation and absolute value of the Fourier transform of the
%   whole series.  The horizontal axis for autocorrelation is labelled in
%   units of coherencesteps, and that for the Fourier transform in units of
%   the total number of coherence periods (i.e. totalsteps/coherencesteps).
%
%   Assuming totalsteps is much larger than coherencesteps, the
%   autocorrelation should have a peak at 0, falling to small amplitude
%   random oscillations outside the interval +/- 0.5.  The Fourier
%   transform should be approximately zero outside the range +/- 2. Within
%   that interval it resembles white noise in a smooth single-peaked
%   envelope.

    X = rand_bac( coherencesteps, totalsteps );

    % Plot X from 1 up to at most coherencesteps*10.
    figure(1);
    plotrange = min(coherencesteps*10,totalsteps);
    plot( (1:plotrange)/coherencesteps, X(1:plotrange) );

    % Plot the autocorrelation of X.  Outside the given window it is
    % close to zero.
    window = coherencesteps*5;
    acX = xcorr( X, window, 'unbiased' );
    range = ((-window):window)/coherencesteps;
    figure(2);
    plot( range, acX/max(acX) );
    
    % Plot the Fourier transform of X.  Outside the given window it is
    % close to zero.
    fftX = fftshift(fft(X))/sqrt(length(X));
    fcoherencesteps = totalsteps/coherencesteps;
    halflength = floor( length(fftX)/2 );
    range = min( floor(fcoherencesteps*5), halflength-1 );
    figure(3);
    plot( ((-range:range)-1)/fcoherencesteps, abs(fftX( (-range:range) + halflength )) );
end
