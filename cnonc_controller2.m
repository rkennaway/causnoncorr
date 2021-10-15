function cnonc_controller2( varargin )
%cnonc_controller2( varargin )
%   This function simulates the proportional controller with two
%   disturbances described in the paper "A common class of systems
%   exhibiting large and robust violations of Faithfulness".
%
%   All arguments are optional and are given as keyword/value pairs, e.g.
%
%       cnonc_controller2( 'reftype', 'step', 'cycles', 100 );
%
%   See the descriptions embedded in the code for what they do.
%
%   The default options are those used in the paper.  This takes about 30
%   seconds to run, less if cohsteps or cycles are reduced.

    % Read options and set defaults.
    s = safemakestruct( mfilename(), varargin );
    s = defaultfields( s, ...
        'outputfile', '', ... % File to write output to.  Defaults to the Matlab console.
        'cohtime', 1, ...  % Coherence time of the random waveform, in virtual seconds.
        'cohsteps', 1000, ... % Number of time steps of the simulation
                          ... % within the coherence time
        'cycles', 1000, ... % Total duration of the simulation as a multiple
                       ... % of the coherence time.
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
        'maxoutput', 0, ... % Zero has no effect, a positive value causes the
                        ... % output of the controller to be clipped to +/- that value.
                        ... % Output clipping is not explored in the paper.
        'DPsize', 1, ... % Amplitude of the disturbance DP.
        'DOsize', 4, ... % Amplitude of the disturbance DO.  This value is chosen
                     ... % so that, empirically, DO is found to have about the
                     ... % same effect on P as DP.
        'restartrng', false, ... % Whether to restart the random number generator
                             ... % from its initial default state at the start
                             ... % of this program.
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
    
    showParams( mfilename(), s );

    % Generate all the random waveforms.
    T = (1:s.totalsteps)*s.dt;
%     DO = randSmoothWaveform( s.cohsteps, s.totalsteps ) * s.DOsize;
%     DP = randSmoothWaveform( s.cohsteps, s.totalsteps ) * s.DPsize;
    DO = randWaveform( 'numsamples', s.totalsteps, ...
                       'type', s.disturbtype, ...
                       'corrtime', s.cohsteps, ...
                       'steplength', s.steplength, ...
                       'steptype', s.steptype, ...
                       'stepinterval', s.cohsteps ) * s.DOsize;
    DP = randWaveform( 'numsamples', s.totalsteps, ...
                       'type', s.disturbtype, ...
                       'corrtime', s.cohsteps, ...
                       'steplength', s.steplength, ...
                       'steptype', s.steptype, ...
                       'stepinterval', s.cohsteps ) * s.DPsize;
    R = randWaveform( 'numsamples', s.totalsteps, ...
                      'type', s.reftype, ...
                      'corrtime', s.cohsteps, ...
                      'steplength', s.steplength, ...
                      'steptype', s.steptype, ...
                      'stepinterval', s.cohsteps ) * s.refratio;
%     if s.stepref
%         R = sin( (0:(s.totalsteps-1))'*(2*pi*s.cycles/s.totalsteps) )*10;
%         R = min( 1, max( -1, R ) );
%     else
%         R = randSmoothWaveform( s.cohsteps, s.totalsteps );
%     end
%     R = R * s.refratio;
    
    fprintf( 1, 'Controller 2: proportional.\nSignal amplitudes: R %.3f, DO %.3f, DP %.3f\n\n', ...
        s.refratio, s.DOsize, s.DPsize );

    [P,O] = run_controller2( DO, DP, R, s );
%     P = zeros(s.totalsteps,1);
%     intO = zeros(s.totalsteps,1);
%     intO(1) = P(1) - DP(1);
%     O = zeros(s.totalsteps,1);
%     
%     for i=1:s.totalsteps-1
%         [P(i),O(i),intO(i+1)] = controller2( intO(i), DO(i), DP(i), R(i), s );
%     end
%     [P(end),O(end),~] = controller2( intO(end), DO(end), DP(end), R(end), s );
    plotcontrol( 'Ex4: Proportional controller', s, ...
        T, ...
        [O/10, P, R, R-P, DO, DP], ...
        { 'O', 'P', 'R', 'E', 'DO', 'DP' }, ...
        { 'O/10', 'P', 'R', 'E', 'DO', 'DP' } );
    printCovars( fid, [O P R R-P DO DP], ...
        { 'O', 'P', 'R', 'E', 'DO', 'DP' } );

    fprintf( 1, '\n' );
end

