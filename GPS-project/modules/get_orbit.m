function [dRs,dRs_dot,IODE] = get_orbit(orbit_arr,prn,gs)
     % 동일한 prn, gs 지나지 않은 시간
     orbit_arr = orbit_arr(orbit_arr(:,3) == prn & orbit_arr(:,1) <= gs,:);
     % 만약 없으면 return 0;
     if isempty(orbit_arr)
        dRs = 0;
        dRs_dot = 0;
        IODE = [];
        return
     end

     % 그중 가장 가까운거   
     [~,idx] = min(orbit_arr(:,1)-gs);
     line = orbit_arr(idx,:);
     dRs = line(5:7)';
     dRs_dot = line(8:10)';
     IODE = line(4);
     
end

