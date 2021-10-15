function [P,O] = run_controller2( DO, DP, R, s )
%[P,O] = run_controller2( DO, DP, R, s )
%   Given waveforms for the two disturbances and the reference, run the
%   proportional controller and return the waveforms of the perception and
%   the output.

    P = zeros(s.totalsteps,1);
    intO = zeros(s.totalsteps,1);
    intO(1) = P(1) - DP(1);
    O = zeros(s.totalsteps,1);
    
    for i=1:s.totalsteps-1
        currentIntO = intO(i);
        if i <= s.lagsteps
            laggedIntO = 0;
        else
            laggedIntO = intO(i-s.lagsteps);
        end
        if i==s.totalsteps
            [P(i),O(i),~] = controller2( currentIntO, laggedIntO, DO(i), DP(i), R(i), s );
        else
            [P(i),O(i),intO(i+1)] = controller2( currentIntO, laggedIntO, DO(i), DP(i), R(i), s );
        end
    end
    
    stdE = std(R-P);
    rejectionRatioP = std(DP)/stdE;
    rejectionRatioO = std(DO)/stdE;
    fprintf( 1, 'Rejection ratio  DP %f  DO %f\n', rejectionRatioP, rejectionRatioO );
end

function [P,O,newintO] = controller2( currentIntO, laggedIntO, DO, DP, R, s )
% Simulate one time step of the controller.
    P = DP + laggedIntO;
    O = s.gain*(R - P);
    O = trimreal( O, s.maxoutput );
    newintO = currentIntO + (O+DO)*s.dt;
end

