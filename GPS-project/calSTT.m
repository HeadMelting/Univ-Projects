function [tc,STT] = calSTT(gs, vec_site, eph, ieph)
    CCC = 299792458;
    threshold = 1e-5;
    MaxIter = 10;

    [prev_vec_sat,~]= getSatPos_glo(eph, ieph, gs);
    STT = norm(prev_vec_sat - vec_site)/CCC;
    tc = 0;
    for i = 1 : MaxIter
        tc = gs - STT;
        [next_vec_sat,~] = getSatPos_glo(eph, ieph, tc);

        tsh = norm(next_vec_sat - prev_vec_sat);
        if tsh < threshold
            break;
        else
            prev_vec_sat = next_vec_sat ;
            STT = norm(prev_vec_sat - vec_site)/CCC;
        end
    
    end

end

