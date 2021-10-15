function cnonc_controller1( varargin )
%cnonc_controller1( varargin )
%   This function simulates the integral controller with one
%   disturbance described in the paper "A common class of systems
%   exhibiting large and robust violations of Faithfulness".
%
%   All arguments are optional and are given as keyword/value pairs, e.g.
%
%       cnonc_controller1( 'reftype', 'step', 'cycles', 100 );
%
%   See the descriptions embedded in the code for what they do.
%
%   The default options are those used in the paper.  This takes about a
%   minute to run, less if cohsteps or cycles are reduced.

    global s T Rbase D0base D1base

    % Read options and set defaults.
    s = safemakestruct( mfilename(), varargin );
    s = defaultfields( s, ...
        'outputfile', '', ... % File to write output to.  Defaults to the Matlab console.
        'cohtime', 1, ...  % Coherence time of the random waveform, in virtual seconds.
        'cohsteps', 1000, ... % Number of time steps of the simulation
                          ... % within the coherence time
        'cycles', 1000, ... % Total duration of the simulation as a multiple
                       ... % of the coherence time.
        'dvratio', 0.1, ... % Ratio of the variance of the unmeasured
                        ... % disturbance D1 to the total disturbance D = D0 + D1.
        'gain', 100, ... % Gain of the controller.  For accuracy of the
                     ... % simulation, cohsteps/cohtime should be at least
                     ... % 10 times the gain.
        'lag', 0.0, ... % The transport lag, in virtual seconds.  If this is
                     ... % larger than about 1.5/gain then the system is unstable.
                     ... % Below this limit the presence of lag makes little
                     ... % difference to the correlations or the rejection
                     ... % ratio.
        'disturbtype', 'smooth', ... % This is used as the 'type' argument for randWaveform
                                 ... % when generating the disturbance.
        'reftype', 'smooth', ... % This is used as the 'type' argument for randWaveform
                             ... % when generating the reference.
        'steplength', 0, ... % This is used as the 'steplength' argument for
                         ... % randWaveform when generating step waveforms.
                         ... % Zero gives instantaneous steps.
        'steptype', 'ramp', ... % This is used as the 'steptype' argument for
                            ... % randWaveform when generating step waveforms.
        'refratio', 1, ... % The amplitude of R.
        'sampleratio', 1, ... % The number of timesteps between samples used for plotting.
        'samplecohtimes', 10, ... % The time interval of the data used for
                              ... % plotting, as a multiple of the coherence time.
        'plotting', true, ... % False will turn off all plotting and just
                          ... % print out the correlation tables.
        'maxoutput', 0, ... % Zero has no effect, a positive value causes the
                        ... % output of the controller to be clipped to +/- that value.
                        ... % Output clipping is not explored in the paper.
        'restartrng', false, ... % Whether to restart the random number generator
                             ... % from its initial default state at the start of this program.
        'colors', defaultPlotColors(), ...
        'linetypes', struct( 'R', ':') ... % R is plotted with a dashed line.
    );

    if isempty( s.outputfile )
        fid = 1;
    else
        fid = open( s.outputfile, 'w' );
        if fid==-1
            fprintf( 1, '%s: cannot write to output file "%s".\n', ...
                mfilename, s.outputfile );
            return;
        end
    end
    
    if s.restartrng
        % Restart the random number generator from its default state.
    	rng('default');
    end
    s.dt = s.cohtime/s.cohsteps;
    s.totalsteps = s.cohsteps * s.cycles;
    s.lagsteps = round(s.lag/s.dt);
    s.samplecohtimes = min( s.samplecohtimes, s.cycles );
    
    showParams( mfilename(), s );

    % Generate all the random waveforms.
    T = (1:s.totalsteps)*s.dt;
    D0base = randWaveform( 'numsamples', s.totalsteps, ...
                           'type', s.disturbtype, ...
                           'corrtime', s.cohsteps, ...
                           'steplength', s.steplength, ...
                           'steptype', s.steptype, ...
                           'stepinterval', s.cohsteps );
    D1base = randWaveform( 'numsamples', s.totalsteps, ...
                           'type', s.disturbtype, ...
                           'corrtime', s.cohsteps, ...
                           'steplength', s.steplength, ...
                           'steptype', s.steptype, ...
                           'stepinterval', s.cohsteps );
    Rbase = randWaveform( 'numsamples', s.totalsteps, ...
                           'type', s.reftype, ...
                           'corrtime', s.cohsteps, ...
                           'steplength', s.steplength, ...
                           'steptype', s.steptype, ...
                           'stepinterval', s.cohsteps );
%     switch s.disturbtype
%         case 'step'
%             D0base = sin( (0:(s.totalsteps-1))'*(2*pi*s.cycles/s.totalsteps) )*10;
%             D0base = min( 1, max( -1, D0base ) );
%             D1base = cos( (0:(s.totalsteps-1))'*(2*pi*s.cycles/s.totalsteps) )*10;
%             D1base = min( 1, max( -1, D1base ) );
%         case 'smooth'
%             D0base = randSmoothWaveform( s.cohsteps, s.totalsteps );
%             D1base = randSmoothWaveform( s.cohsteps, s.totalsteps );
%         case 'randstep'
%             D0base = randStepWaveform( s.cohsteps, s.totalsteps );
%             D1base = randStepWaveform( s.cohsteps, s.totalsteps );
%         otherwise
%             error( '%s: Unknown disturbance type %s (smooth, step, or randstep required).\n', ...
%                 s.disturbtype );
%     end
%     if s.stepref
%         Rbase = sin( (0:(s.totalsteps-1))'*(2*pi*s.cycles/s.totalsteps) )*10;
%         Rbase = min( 1, max( -1, Rbase ) );
%     elseif strcmp( s.disturbtype, 'smooth' )
%         Rbase = randSmoothWaveform( s.cohsteps, s.totalsteps );
%     else
%         Rbase = randStepWaveform( s.cohsteps, s.totalsteps );
%     end
    plotController1( fid, 'Ex1: Zero R, varying D, prop. controller', 0, 0 );
    plotController1( fid, 'Ex2: Varying R and D, prop. controller', s.refratio, 0 );
    plotController1( fid, 'Ex3: Zero R, varying D, only D0 measured, prop. controller', 0, sqrt(s.dvratio) );

    fprintf( 1, '\n' );
end

function plotController1( fid, name, Rsize, D1size )
    global s T Rbase D0base D1base
    
    D0size = sqrt(1 - D1size^2);
    fprintf( fid, 'Controller 1: integral.\nSignal amplitudes: R %.3f, D %.3f.\n\n', Rsize, D0size );
    R = Rbase * Rsize;
    D0 = D0base * D0size;
    D1 = D1base * D1size;
    D = D0 + D1;

    [P,O] = run_controller1( D, R, s );
    E = R-P;
    
    rejectionRatio = std(D)/std(E);
    fprintf( fid, 'Rejection ratio std(D)/std(E) = %f\n', rejectionRatio );
    
    if Rsize==0
        if D1size==0
            plotcontrol( name, s, ...
                T, [O, P, D, R], { 'O', 'P', 'D', 'R' } );
            printCovars( fid, [O P D], ...
                { 'O', 'P', 'D' } );
        else
            plotcontrol( name, s, ...
                T, [O, P, R, D0, D1], { 'O', 'P', 'R', 'D0', 'D1' } );
            printCovars( fid, [O P O+D0 D0 D1 D], ...
                { 'O', 'P', 'O+D0', 'D0', 'D1', 'D' } );
        end
    else
        if D1size==0
            plotcontrol( name, s, ...
                T, [O, P, R, E, D], { 'O', 'P', 'R', 'E', 'D' } );
            printCovars( fid, [O P R E D], ...
                { 'O', 'P', 'R', 'E', 'D' } );
        else
            plotcontrol( name, s, ...
                T, [O, P, R, E, D0, D1], { 'O', 'P', 'R', 'E', 'D0', 'D1' } );
            printCovars( fid, [O P R E O+D0 D0 D1 D], ...
                { 'O', 'P', 'R', 'E', 'O+D0', 'D0', 'D1', 'D' } );
        end
    end
    
    [xc,lags] = xcorr( [O P D], max( s.lagsteps*3, s.cohsteps ), 'unbiased' );
    % xc(:,i) records the
    % cross-correlations between the i'th pair of variables, i.e. xc(:,1)
    % is the autocorrelation function of O, xc(:,2) the cross-correlation
    % function of O and P, etc.
    fig = figure;
    set( fig, 'Name', [name, ' ', 'Cross-correlations'] );
    hold on
    for i=1:size(xc,2)
        plot(lags/s.cohsteps,xc(:,i),'.-');
    end
    hold off
end

