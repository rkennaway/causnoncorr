function corr_makefig( fignum, title, xlab, ylab, mark, ...
                       xdata, ydata, axrange, Xticks, Yticks )
% For plotting Figure 1(a-e) of the paper.

    if nargin < 9
        Xticks = [];
    end
    if nargin < 10
        Yticks = [];
    end
    TICKFONTSIZE = 20;
    FONTSIZE = 20;
    FONTWEIGHT = 'bold';
    FIGWIDTH = 500;
    FIGHEIGHT = 400;
    MARGIN = [ TICKFONTSIZE*3, 33 + FONTSIZE + TICKFONTSIZE, TICKFONTSIZE, TICKFONTSIZE ];
    AXISPOSITION = [ MARGIN([1 2]) [FIGWIDTH FIGHEIGHT] - MARGIN([1 2])-MARGIN([3 4])];
    
    fig = figure( fignum );
    clf;
    set( fig, 'Name', title, 'Color', [1 1 1], 'Units', 'pixels' );
    p = get( fig, 'Position' );
    dp = [FIGWIDTH FIGHEIGHT] - p([3 4]);
    p = [p([1 2])-dp/2, p([3 4])+dp ];
    set( fig, 'Position', p );
    movegui( fig, 'center' );
    foregroundaxes = axes( 'Parent', fig );
    set( foregroundaxes, 'Units', 'pixels', 'Position', AXISPOSITION, 'FontSize', TICKFONTSIZE );
    set( foregroundaxes, 'Units', 'normalized' );
    plot( xdata, ydata, mark, 'LineWidth', 1, 'MarkerSize', 15 );
    axis(axrange);
    if (axrange(1)==axrange(3)) && (axrange(2)==axrange(4))
        axis square
    end
    xlabel( xlab, 'FontSize', FONTSIZE, 'FontWeight', FONTWEIGHT );
    ylabel( ylab, 'FontSize', FONTSIZE, 'FontWeight', FONTWEIGHT, 'Rotation', 0 );
    if ~isempty(Xticks)
        set( foregroundaxes, 'XTick', Xticks );
    end
    if ~isempty(Yticks)
        set( foregroundaxes, 'YTick', Yticks );
    end
    drawnow;
    f = getframe( fig );
    imwrite( f.cdata, ['fig1', char('a'+fignum-1), '.png'], 'png' );
    print( fig, ['fig1p', char('a'+fignum-1), '.png'], '-r300', '-dpng' );
end
