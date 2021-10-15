function r = rand_bac( coherencesteps, totalsteps )
%r = rand_bac( coherencesteps, totalsteps )
%   Generate random time series with bounded autocorrelation.
%
%   This procedure returns a column vector of random numbers of length
%   TOTALSTEPS, whose autocorrelation is zero for lags greater than or
%   equal to COHERENCESTEPS.  The numbers are normally distributed with
%   mean 0 and standard deviation 1.

    delta = 1/coherencesteps;
    k = (1:coherencesteps)*delta - 0.5 - delta/2;
    kernel = exp( -1./(0.5 - k.^2).^2 );
    kernel = kernel/sum(kernel);
    % Kernel is a discrete approximation to a real function on the interval
    % -0.5..0.5.  When it is defined to be zero outside that interval, it is
    % infinitely differentiable on the whole real line.  The sum of all of
    % its sampled values is 1.

    r = imfilter( randn( 1, totalsteps ), kernel, 'circular', 'conv' )'/norm(kernel);
    r = r - sum(r)/length(r);
    r = r/std(r);
    % r is the convolution of kernel with white noise, with mean forced to
    % 0 and standard deviation forced to 1.
    % It has zero autocorrelation for all time lags greater than or equal
    % to coherencesteps.  It is also a discrete approximation to an
    % infinitely differentiable function.
end