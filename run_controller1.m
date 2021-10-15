function [P,O,Odot] = run_controller1( D, R, s )
%[P,O,Odot] = run_controller1( D, R, s )
%   Given waveforms for the disturbance and the reference, run the
%   integral controller and return the waveforms of the perception,
%   the output, and the rate of change of the output.

    P = zeros(size(D));
    % The control system is started in a state of zero error, to avoid
    % artefacts due to a starting transient.
    P(1) = R(1);
    O = zeros(size(D));
    O(1) = P(1) - D(1);
    Odot = zeros(size(D));
    for i=1:length(D)
        currentO = O(i);
        if i <= s.lagsteps
            laggedO = 0;
        else
            laggedO = O(i - s.lagsteps);
        end
        if i==length(D)
            [P(i),Odot(i),~] = controller1( currentO, laggedO, D(i), R(i), s );
        else
            [P(i),Odot(i),O(i+1)] = controller1( currentO, laggedO, D(i), R(i), s );
        end
    end
end
