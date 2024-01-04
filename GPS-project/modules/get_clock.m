function [c0,c1,c2,IODE_CHECK] = get_clock(clock_arr,prn,gs,IODE)
     % 동일한 prn, gs 지나지 않은 시간
     clock_arr = clock_arr(clock_arr(:,3) == prn & clock_arr(:,1) <= gs,:);
     % 만약 없으면 return 0;
     if isempty(clock_arr)
        c0 = 0;
        c1 = 0;
        c2 = 0;
        IODE_CHECK = 0;
        return
     end

     % 그중 가장 가까운거   
     [~,idx] = min(clock_arr(:,1)-gs);
     line = clock_arr(idx,:);
     if line(4) == IODE
         c0 = line(5);
         c1 = line(6);
         c2 = line(7);
         IODE_CHECK = 1;
     else
        c0 = 0;
        c1 = 0;
        c2 = 0;
        IODE_CHECK = 0;
        fprintf("wtf");
        return
     end
end

