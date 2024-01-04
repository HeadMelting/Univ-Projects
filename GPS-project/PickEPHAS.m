function [ieph] = PickEPHAS(eph, prn, gs, IODE)
% 차이가 7200이내
idxs = find(eph(:,2) == prn & abs(eph(:,1) - gs) <= 7200 & eph(:,8) == IODE);
[~, idx] = min(eph(idxs,1) - gs);


if isempty(idx)
    ieph = 0;
    return
else
    ieph = idxs(idx);
end

end

