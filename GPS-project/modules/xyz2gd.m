function [geodetic] = xyz2gd(ECEF)
    %% ECEF X,Y,Z 가져오기
    X = ECEF(1); Y = ECEF(2); Z = ECEF(3); 
    
    
    %% GRS80 : a = 6378137.0; b = 6356752.314;
    a = 6378137.0; 
    b = 6356752.314;
    e = sqrt((a^2 - b^2)/a^2);

    %% 1. p = sqrt(x^2 + y^2) 계산
    p = sqrt(X^2 + Y^2);

     % 범위가 [-pi,pi]로 만들기 위해서 atan2 사용한다
    lamda = atan2(Y,X)*180 / pi; 

    if lamda > 180.
        lamda = lamda - 360.;
    elseif lamda < -180.
        lamda = lamda + 360.;
    end
   


    %% 2. 타원체고 h의 초기값을 0으로 하고 위도근사치 phi_0 계산
    phi_0 = atan(Z/p*(1 - e^2)^-1);
    stopCondition = 1;
    phi = 0;
    h = 0;
    maxIter = 0;
     
    while (stopCondition > 1e-15)
    %% 3. N의 근사치 N_0를 계산한다
     N_0 = a^2 / sqrt(a^2*(cos(phi_0))^2 + b^2*(sin(phi_0))^2);

    %% 4. 타원체고 h의 값을 갱신한다
     h = p/cos(phi_0) - N_0;

    %% 5. 위도 계산값을 갱신
     phi = atan(Z*(1 - e^2*(N_0/(N_0 + h)))^-1/p);

    %% 6. stop
     stopCondition = abs(phi - phi_0);
     phi_0 = phi;

    %% 6. maxIter = maxIter + 1;
        
        maxIter = maxIter + 1;

%         fprintf("#%2.0f ,phi0 : %12.6f\n", maxIter,phi_0);
        
        if maxIter > 100
            break;
        end


    end

        
    geodetic = [phi*180/pi, lamda, h];
end


