function cnonc_VI( varargin )
%cnonc_VI()
%   Plot the voltage/current graphs appearing in the paper.
%   Figure 1: V with respect to time.  A random waveform.
%   Figure 2: I with respect to time.  The derivative of the waveform of
%       Figure 1.
%   Figure 3: I with respect to V, plotted with a short time interval.
%   Figure 4: As 3, with a long time interval, and the points joined up.
%   Figure 5: As 4, with many more points, not joined up.
%   In all plots, V and I are measured in units of their respective
%       standard deviations.
%   The plots are saved as both screen grabs and higher-resolution versions
%   suitable for print.
%
%   Arguments are alternating keyword/value pairs.  Allowed arguments are:
%   coherencesteps: A positive integer, default 200.  The autocorrelation
%       function for both V and I will be zero at intervals this length or
%       longer.  This is also the sampling interval for Figures 4 and 5.
%   coherencetime: A positive real number, default 1.  The notional time
%       corresponding to coherencesteps steps.  The appearance of
%       all the figures is independent of this value, except that it
%       defines the timescale of the t axis in Figures 1 and 2.
%   numcycles: A positive integer, default 10.  The duration of the
%       simulation, measured in units of the coherence time.
%   bignumcycles: A positive integer, default 1000.  The duration of the
%       simulation plotted in Figure 5, measured in units of the coherence
%       time.  This will also be the number of sample points plotted.

    s = safemakestruct( mfilename(), varargin );
    s = defaultfields( s, ...
        'coherencesteps', 200, ...
        'coherencetime', 1, ...
        'numcycles', 10, ...
        'bignumcycles', 1000 ...
    );
    dt = s.coherencetime/s.coherencesteps;
        % The notional timestep of the simulation,
        % chosen to make the coherence time equal to
        % 1 second.
    totalsteps = s.coherencesteps * s.numcycles;
    x = rand_bac( s.coherencesteps, totalsteps );
    V = (x + x([2:end 1]))/2;
    I = (x([2:end 1]) - x)/(2*dt);
    V = V/std(V);
    I = I/std(I);
    sampleV = V(s.coherencesteps:s.coherencesteps:totalsteps);
    sampleI = I(s.coherencesteps:s.coherencesteps:totalsteps);
    
    VImax = max( max( max(V), max(I) ), -min( min(V), min(I) ) );
    VImax = max( VImax, 3 );
    VImax = 1.05 * VImax;
    VIaxrange = [ -VImax, VImax, -VImax, VImax ];
    VITrange = [ 0, length(V)*dt, -VImax, VImax ];
    
    corr_makefig( 1, 'VI: Random smooth V', 't', 'V', '.-k', (1:length(V))*dt, V, VITrange, [], -3:3 );
    corr_makefig( 2, 'VI: Random smooth I', 't', 'I', '.-k', (1:length(V))*dt, I, VITrange, [], -3:3 );
    corr_makefig( 3, 'VI: I vs. V, fine timescale', 'V', 'I', '.-k', V, I, VIaxrange, -3:3, -3:3 );
    corr_makefig( 4, ...
        sprintf( 'VI: I vs. V, coarse timescale, %d points', length(sampleV) ), ...
            'V', 'I', '.-k', sampleV, sampleI, VIaxrange, -3:3, -3:3 );

    biggertotalsteps = s.coherencesteps * s.bignumcycles;
    x = rand_bac( s.coherencesteps, biggertotalsteps );
    V = (x + x([2:end 1]))/2;
    I = (x([2:end 1]) - x)/(2*dt);
    V = V/std(V);
    I = I/std(I);
  % corrVI = corr( [V,I] )
    sampleV = V(s.coherencesteps:s.coherencesteps:biggertotalsteps);
    sampleI = I(s.coherencesteps:s.coherencesteps:biggertotalsteps);
  % corrSampledVI = corr( [sampleV,sampleI] )
    corr_makefig( 5, ...
        sprintf( 'I vs. V, coarse timescale, %d points', length(sampleV) ), ...
            'V', 'I', '.k',sampleV, sampleI, VIaxrange, -3:3, -3:3 );
end

