function X = randWaveform( varargin )
%X = randWaveform( option1, value1, option2, value2, ... )
%   Generate a random waveform.
%
%   Options:
%
%   'numsamples'    The number of samples to generate.
%   'type'          One of 'smooth', 'onestep', or 'step'.
%                   'smooth' will generate a smoothly varying waveform
%                   whose long-term statistics are Gaussian.  'onestep'
%                   generates a step from 0 to 1 at time zero.  The first
%                   sample is guaranteed to be 0, and the time taken to
%                   reach 1 is determined by other options.  'step'
%                   generates random steps back and forth between 0 and 1.
%   'corrtime'      When 'type' is 'smooth', this specifies the
%                   autocorrelation time of the waveform.  Samples that are
%                   separated in time by this amount of more will have zero
%                   correlation with each other.
%   'steplength'    The number of time steps it takes for a step to go from
%                   0 to 1.  The minimum value for this is 1: a zero sample
%                   is immediately followed by a 1, or vice versa.
%   'steptype'      Either 'ramp' or 'sine'.  'ramp' generates the step as
%                   a linear ramp, while 'sine' generates it as half a sine
%                   wave.
%   'stepinterval'  When 'type' is 'step', this specifies the average
%                   interval between the end of one step and the beginning
%                   of the next.  The actual intervals will have an
%                   exponential distribution.

    s = safemakestruct( mfilename(), varargin );
    s = defaultfields( s, ...
        'numsamples', 1010, ...
        'type', 'smooth', ...
        'corrtime', 100, ...
        'steplength', 100.5, ...
        'steptype', 'sine', ...
        'stepinterval', 20.5 ...
    );

    switch s.type
        case 'smooth'
            X = randSmoothWaveform( s.corrtime, s.numsamples );
        case 'onestep'
            X = [ step( s.steplength, 0, s.steptype, 0, 1 ), ones( 1, s.numsamples - s.steplength - 1 ) ]';
        case 'step'
            X = zeros(1,s.numsamples);
            curtime = 1;
            steptimes = [];
            while true
                waittime = -log(rand()) * s.stepinterval;
                curtime = curtime + waittime;
                if curtime > s.numsamples
                    break;
                end
                steptimes(end+1) = curtime;
                curtime = curtime + s.steplength;
                if curtime > s.numsamples
                    break;
                end
            end
            curval = 0;
            xi = 1;
            for i=1:length(steptimes)
                stepstart = floor(steptimes(i));
                Y = step( s.steplength, mod( steptimes(i), 1 ), s.steptype, curval, 1-curval );
                X(xi:stepstart) = curval;
                xi = stepstart+1;
                stepend = stepstart + length(Y);
                excess = max( stepend-length(X), 0 );
                X(xi:(stepend-excess)) = Y(1:(end-excess));
                curval = 1-curval;
                xi = stepend-excess+1;
            end
            if xi <= length(X)
                X(xi:end) = curval;
            end
            X = X';
        otherwise
            X = zeros(s.numsamples,1);
            fprintf( 1, 'Invalid waveform type ''%s''.\n', s.type );
    end
end

function X = step( steplength, fractime, type, lo, hi )
    if steplength <= 0
        X = [];
        return;
    end
    times = ((0:(steplength-1)) + fractime)/steplength;
    switch type
        case 'ramp'
            X = lo + times*(hi-lo);
        case 'sine'
            X = (hi+lo)/2 + ((hi-lo)/2)*cos((times-1)*pi);
            X(end) = [];
        otherwise
            X = zeros( 1, steplength );
            fprintf( 1, 'Invalid step type ''%s''.\n', type );
    end
end
