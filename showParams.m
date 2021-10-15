function showParams( msg, s )
	fprintf( 1, '%s params:\n', msg );
    fns = sort( fieldnames(s) );
    for i=1:length(fns)
        fn = fns{i};
        fprintf( 1, '    %s = ', fn );
        v = s.(fn);
        if islogical(v)
            if v
                fprintf( 1, 'true' );
            else
                fprintf( 1, 'false' );
            end
        elseif isnumeric(v)
            if v==round(v)
                fprintf( 1, '%d', v );
            else
                fprintf( 1, '%g', v );
            end
        elseif ischar(v)
            fwrite( 1, v );
        else
            fprintf( 1, '***' );
        end
        fprintf( 1, '\n' );
    end
    fprintf( 1, '\n' );
end
