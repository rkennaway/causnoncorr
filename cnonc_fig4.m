function cnonc_fig4( varargin )
%cnonc_fig4()
%   This function generates the graphs in Figure 4.  They are saved as both
%   screen grabs and higher-resolution versions suitable for print.
%
%   Arguments are alternating keyword/value pairs.
%   See the descriptions embedded in the code for what they do.

    s = safemakestruct( mfilename(), varargin );
    s = defaultfields( s, ...
        'restartrng', false, ... % Restart the random number generator from
                            ... % its default initial state.
        'resolution', 100, ... % Number of time steps per the characteristic
                           ... % time of the controller (= 1/s.gain).
        'cycles', 6, ... % The multiple of the coherence time to run the
                     ... % step examples for.
        'gain', 100, ... % Gain of the controller.
        'lag', 0.0, ... % The transport lag, in virtual seconds.  If this is
                     ... % larger than about 1.5/gain then the system is unstable.
                     ... % Below this limit the presence of lag makes little
                     ... % difference to the correlations or the rejection
                     ... % ratio.
        'refratio', 0 ... % Ratio of reference amplitude to disturbance amplitude.
        );
    
    if s.restartrng==0
        
        rng( 'default' );
    end

    char_time = 1/s.gain;
    s.dt = char_time/s.resolution;
    s.lagsteps = round(s.lag/s.dt);
    totalsteps = s.resolution * s.cycles + 1;
    T = ((0:(totalsteps-1)) - s.resolution)*s.dt;
    xrange = [ T(1), T(end) ];
    xticks = xrange(1):0.01:xrange(2);

    initial_length = floor( (totalsteps-1)/6 );
    D = [ zeros( initial_length, 1 ); ones( totalsteps-initial_length, 1 )];
    R = zeros( totalsteps, 1 );
    [P,O] = run_controller1( D, R, s );
    plotcontrol( 1, 1, T, O, P, R, D, 1, xticks );
    
    R = D;
    D = zeros( totalsteps, 1 );
    [P,O] = run_controller1( D, R, s );
    plotcontrol( 2, 1, T, O, P, R, D, 1, xticks );
    
    cohtimek = 40;
    cohsteps = cohtimek * s.resolution;
    cohcycles = 30;
    totalsteps = cohsteps * cohcycles + 1;
    T = (0:(totalsteps-1))*s.dt;
    xticks = linspace( T(1), T(end), cohcycles/10+1 );
    R = zeros( totalsteps, 1 );
    D = rand_bac( cohsteps, totalsteps );
    [P,O] = run_controller1( D, R, s );
    plotcontrol( 3, 100, T, O, P, R, D, 3, xticks );
    printstats( 'Varying D, constant R', {'O','P','D'}, [O, P, D], round(cohsteps*1.618) );
    
    R = rand_bac( cohsteps, totalsteps );
    [P,O] = run_controller1( D, R, s );
    plotcontrol( 4, 100, T, O, P, R, D, 3, xticks );
    printstats( 'Varying R and D', {'O','P','R','D'}, [O, P, R, D], round(cohsteps*1.618) );    
end

function printstats( heading, labels, data, cohsteps ) % O, P, R, D )
    fprintf( 1, '%s\n\n', heading );
    data = data(1:cohsteps:end,:);
    numvars = size(data,2);
    corrs = corr( data );
    mutinf = log( 1 ./ sqrt( 1 - corrs.^2 ) );
    covs = cov( data );
    vars = diag(covs);
    stds = sqrt(vars);
    for i=1:(numvars-1)
        for j=i+1:numvars
            fprintf( 1, '%s-%s: cov %.2g, r %.2g, I %.2g\n', ...
                labels{i}, labels{j}, covs(i,j), corrs(i,j), mutinf(i,j) );
        end
    end
    for i=1:numvars
        fprintf( 1, '%s var %.2g, std %.2g\n', labels{i}, vars(i), stds(i) );
    end
    if numvars==3
        rejectionratio = vars(3)/vars(2);
    else
        rejectionratio = vars(4)/cov(data(:,3)-data(:,2));
    end
    rrdb = 10*log10(rejectionratio);
    fprintf( 1, 'Rejection ratio (variance)  %.3g db\n', rrdb );
    fprintf( 1, 'Rejection ratio (amplitude) %.3g db\n', rrdb/2 );
    fprintf( 1, '\n' );
end

function X = startatzero( X )
    X = X - sum(X)/length(X);
    [xmin,xi] = min(abs(X));
    X = X( [xi:end 1:(xi-1)] );
end

function plotcontrol( fignum, sampleratio, T, O, P, R, D, yrange, xticks )
    if sampleratio > 1
        T = T(1:sampleratio:end);
        O = O(1:sampleratio:end);
        P = P(1:sampleratio:end);
        R = R(1:sampleratio:end);
        D = D(1:sampleratio:end);
    end
    E = R-P;
    
    yticklength = 0.01*(T(end)-T(1));
    fig = figure(fignum);
    clf;
    set( fig, 'Position', [100 100 800 800], 'Color', [1 1 1] );
    trackheight = 2*yrange;
    trackmargin = 0.35*yrange;
    xaxisheight = yrange;
    numtracks = 5;
    trackspacing = trackheight+trackmargin;
    firsttrackcentre = xaxisheight + trackmargin + trackspacing/2;
    axisheight = xaxisheight + trackmargin + numtracks*trackspacing;
    ax = axes( 'Position', [0 0 1 1], 'Parent', fig );
    hold on;

    plottrack( ax, T, D, yrange, firsttrackcentre + 4*trackspacing, 'D' );
    plottrack( ax, T, R, yrange, firsttrackcentre + 3*trackspacing, 'R' );
    plottrack( ax, T, P, yrange, firsttrackcentre + 2*trackspacing, 'P' );
    plottrack( ax, T, O, yrange, firsttrackcentre + 1*trackspacing, 'O' );
    plottrack( ax, T, E, yrange, firsttrackcentre + 0*trackspacing, 'E' );

    trange = [T(1) T(end)];
    xlength = trange(2) - trange(1);
    line( trange', [xaxisheight;xaxisheight], ...
          'Color', [0 0 0], 'LineWidth', 2 );
    xticklength = 0.1*yrange;
    for i=xticks
        line( [i;i], ...
              [xaxisheight-xticklength;xaxisheight+xticklength], ...
              'Color', [0 0 0], 'LineWidth', 2 );
        text( i, xaxisheight - xticklength*1.5, ...
              float2string( i ), ...
              'FontWeight', 'normal', ...
              'FontSize', 28, ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'top' );

    end

    axis( [trange(1)-xlength*0.16 trange(2)+xlength*0.08 0 axisheight] );
    axis off;
    hold off;
  % print( '-r600', '-dpng', sprintf( 'fig4_%d.png', fignum ) );

    f = getframe( fig );
    imwrite( f.cdata, ['fig4', char('a'+fignum-1), '.png'], 'png' );
    print( fig, ['fig4p', char('a'+fignum-1), '.png'], '-r300', '-dpng' );

function plottrack( ax, times, track, yrange, yoffset, label )
    xrange = [times(1) times(end)];
    plot( times, track+yoffset, '-k', 'LineWidth', 4 );
    line( [xrange(1) xrange(1)], [yoffset-yrange; yoffset+yrange], ...
        'Color', [0 0 0], 'LineWidth', 2 );
    line( xrange(1) + [-yticklength;yticklength], [yoffset-yrange; yoffset-yrange], ...
        'Color', [0 0 0], 'LineWidth', 2 );
    line( xrange(1) + [-yticklength;yticklength], [yoffset+yrange; yoffset+yrange], ...
        'Color', [0 0 0], 'LineWidth', 2 );
    text( xrange(1) - yticklength*6, yoffset, label, ...
        'FontWeight', 'normal', ...
        'FontSize', 28, ...
        'HorizontalAlignment', 'right' );

    text( xrange(1) - yticklength*2, yoffset-0.85*yrange, sprintf( '%d', round(-yrange) ), ...
        'FontWeight', 'normal', ...
        'FontSize', 28, ...
        'HorizontalAlignment', 'right' );
    text( xrange(1) - yticklength*2, yoffset+0.85*yrange, sprintf( '%d', round(yrange) ), ...
        'FontWeight', 'normal', ...
        'FontSize', 28, ...
        'HorizontalAlignment', 'right' );
end
end

function setaxisparams( t, range, ylabel, i, n )
    bottomgap = 0.05;
    gap = 0.15;
    ht = (1-bottomgap)/(n*gap + n + gap);
    gutter = ht*gap;
    ylo = 1 - i*(ht+gutter) ;
    xlo = 0.1;
    xwidth = 1 - xlo - gutter;
    ywidth = ht;
    axis( [0 t -range range] );
    set( get(gca, 'YLabel'), 'String', ylabel, 'Rotation', 0, ...
        'FontWeight', 'bold', 'FontSize', 30 );
    if i < n
        set( gca, 'XColor', [1 1 1], 'XTick', [], 'XTickLabel', [] );
    else
        set( gca, 'XColor', [0 0 0] ); %, 'XTick', [0 0.025 0.05] );
    end
    set( gca, 'YTick', [-1 1], ...
        'Position', [ xlo, ylo, xwidth, ywidth ] );
    fprintf( 1, 'Position of graph %s %d/%d: [ %f %f %f %f]\n', ...
        ylabel, i, n, get(gca,'Position') )
end

function s = float2string( f )
    s = sprintf( '%f', f );
    s = regexprep( s, '0*$', '' );
    s = regexprep( s, '\.$', '' );
end
