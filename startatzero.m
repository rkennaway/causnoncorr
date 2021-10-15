function X = startatzero( X )
    % Set the mean of X to zero
    X = X - sum(X)/length(X);
    % Find the element with smallest absolute value.
    [~,xi] = min(abs(X));
    % Rotate the sequence to bring that element to the beginning.
    X = X( [xi:end 1:(xi-1)] );
end

