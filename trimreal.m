function o = trimreal( o, maxo )
%o = trimreal( o, maxo )
%   Force o to lie in the range +/- maxo.

    if maxo > 0
        if o > maxo
            o = maxo;
        elseif o < -maxo
            o = -maxo;
        end
    end
end

