function X = randStepWaveform( cohsteps, totalsteps )
%X = randStepWaveform( cohsteps, totalsteps )
%   Generate a random wave form which switches between values of +/- 1.
%   The initial value is equally likely to be either.  Thereafter, the time
%   to next switching is an exponential distribution with characteristic
%   time cohsteps.

    switchpoints = [1];
    finaltime = switchpoints(end);
    deficit = totalsteps-finaltime;
    while deficit > 0
        intervals = -log( rand( ceil(deficit/cohsteps), 1 ) )*cohsteps;
        switchpoints = [ switchpoints; finaltime+cumsum(intervals) ];
        finaltime = switchpoints(end);
        deficit = totalsteps - finaltime;
    end
    switchpoints = unique(round(switchpoints));
    switchpoints = [switchpoints(switchpoints<totalsteps); totalsteps];
    curval = rand(1)<0.5;
    X = zeros( totalsteps, 1 );
    for i=2:length(switchpoints)
        X( switchpoints(i-1):switchpoints(i) ) = curval;
        curval = 1-curval;
    end
end
