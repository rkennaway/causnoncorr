function cq = corrQuadrant( x, y )
%cq = corrQuadrant( x, y )
%   Calculate the quadrant correlation between x and y.

    x = x > sum(x)/length(x);
    y = y > sum(y)/length(y);
    xy = sum(x&y);
    totx = sum(x);
    toty = sum(y);
    disagree = totx + toty - 2*xy;
    agree = length(x) - disagree;
    cq = (agree - disagree)/length(x);
end
