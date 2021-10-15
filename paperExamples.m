function paperExamples( cycles )
%paperExamples( cycles )
%   With no arguments, this runs all the simulations with the same
%   parameters as in the paper.  This is quite time-consuming, and
%   specifying a smaller value for CYCLES than the default (1000) will give
%   results of the same general nature in a shorter time.
%
%   This procedure prints out or plots more information than appears in the
%   paper.

    starttime = tic;
    if nargin < 1
        cycles = 1000;
    end
	cnonc_VI();
    cnonc_fig4();
    cnonc_controller1( 'cycles', cycles );
    cnonc_controller1( 'cycles', cycles, ...
        'gain', '1', 'cohtime', 0.1 );
    cnonc_controller2( 'cycles', cycles );
    toc(starttime);
end
