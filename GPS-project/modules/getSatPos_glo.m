function [CompSatPos,Ek] = getSatPos_glo(eph,ieph,t)

sqrtA = eph(ieph,10);         %: (3,4)
delta_n = eph(ieph,18) ;     %: (2,3)
toe = eph(ieph,1);        %: (4,1)
M0 = eph(ieph,15);           %: (2,4)
e = eph(ieph,11);             %: (3,2)
omega = eph(ieph,13) ;    %: (5,3)
Cuc = eph(ieph,20);          %: (3,1)
Cus =  eph(ieph,21);          %: (3,3)
Crc =  eph(ieph,22);          %: (5,2)
Crs = eph(ieph,23);          %: (2,2)
Cic = eph(ieph,24);          %: (4,2)
Cis = eph(ieph,25);          %: (4,4)
i0 = eph(ieph,12);            %: (5,1)
i_dot = eph(ieph,16);         %: (6,1)
Omega0 = eph(ieph,14);        %: (4,3)
Omega_dot = eph(ieph,17);    %: (5,4)

% Step 1
mu = 3.986005e14;
omegaE = 7.2921151467e-5;

% Step 2
a = sqrtA^2;
n0 = sqrt(mu/a^3);

% Step 3
n = n0 + delta_n;

% Step 4
tk = t - toe;

% Step 5
Mk = M0 + n*tk;

% Step 6
Ek = solveKeplerEq(Mk, e);

% Step 7 
fk =  atan2((sqrt(1 - e^2)*sin(Ek)), (cos(Ek) - e));

% Step 8
phik = fk + omega;

% Step 9
delta_uk = Cus*sin(2*phik) + Cuc*cos(2*phik);
delta_rk = Crs*sin(2*phik) + Crc*cos(2*phik);
delta_ik = Cis*sin(2*phik) + Cic*cos(2*phik);

% Step 10
uk = phik + delta_uk;
rk = a*(1 - e*cos(Ek)) + delta_rk;
ik = i0 + delta_ik + i_dot*tk;

% Step 11
xkp = rk*cos(uk);
ykp = rk*sin(uk);

% Step 12
Omegak = Omega0 + (Omega_dot - omegaE)*tk - omegaE*toe;

% Step 13
xk = xkp*cos(Omegak) - ykp*cos(ik)*sin(Omegak);
yk = xkp*sin(Omegak) + ykp*cos(ik)*cos(Omegak);
zk = ykp*sin(ik);

% 참값과 비교
CompSatPos = [xk, yk, zk];

end

