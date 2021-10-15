function printCovars( fid, data, labels )
    c = corr( data );
    printmat( fid, 'Correlations', labels, c, 'upper' );
    v = cov( data );
    printmat( fid, 'Covariances', labels, v, 'full' );
    variances = var( data );
    fprintf( fid, 'Variances and standard deviations\n\n' );
    for i=1:length(labels)
        fprintf( fid, '%8s', labels{i} );
        fprintf( fid, ' v = %8.3f, sd = %8.3f\n', variances(i), sqrt(variances(i)) );
    end
    fprintf( fid, '\n' );
    
    printAllcovars( fid, data, labels, std(data(:)) * 1e-3 );
end

function printmat( fid, title, labels, matrix, mode )
    upperonly = strcmp(mode,'upper');
    if upperonly
        first = 2;
        last = length(labels)-1;
    else
        first = 1;
        last = length(labels);
    end
    fprintf( fid, '%s\n\n', title );
    fprintf( fid, '        ' );
    fprintf( fid, ' & %8s', labels{first:end} );
    fprintf( fid, ' \\\\\n' );
    for i=1:last
        fprintf( fid, '%8s', labels{i} );
        for j=first:length(labels)
            if (j > i) || ~upperonly
                fprintf( fid, ' & %8.3f', matrix(i,j) );
            else
                fprintf( fid, ' &         ' );
            end
        end
        fprintf( fid, ' \\\\\n' );
    end
    fprintf( fid, '\n' );
end
