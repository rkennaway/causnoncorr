function plotcontrol( title, s, T, data, labels, legendlabels )
    if nargin < 6
        legendlabels = labels;
    end
    Tsample = T( 1:s.sampleratio:(s.samplecohtimes*s.cohsteps) );
    data = data( 1:s.sampleratio:(s.samplecohtimes*s.cohsteps), : );
    fig = figure();
    set( fig, 'Name', title );
    clf;
    hold on;
    for i=1:size(data,2)
        if isfield( s.linetypes, labels{i} )
            linetype = s.linetypes.(labels{i});
        else
            linetype = '-';
        end
        plot( Tsample, data(:,i), linetype, 'LineWidth', 2, 'Color', s.colors.(labels{i}) );
    end
    range = max(1,max(abs(data(:))));
    axis( [0 max(Tsample) -range range] );
    legend( legendlabels{:} );
    hold off;
end

