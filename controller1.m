function [P,Odot,newO] = controller1( currentO, laggedO, D, R, s )
% Simulate one time step of the controller.
% currentO, D, and R are the current values, and P, Odot, and newO are values one
% time step later.
% laggedO is the value used to calculate P, and is the value of O some
% time ago.  This models a transport lag in the environment.

    P = D + laggedO;
    Odot = s.gain*(R - P);
    newO = currentO + Odot*s.dt;
end

