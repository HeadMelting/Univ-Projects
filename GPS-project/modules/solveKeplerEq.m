function Ek = solveKeplerEq(M , e)

% clearvars;
% close all;
% clc;

%% 초기값과 탈출조건 정의

% M = 0.5;
% e = 0.005;
eps = 1e-15;

Ek = M;

for k = 1 : 10
    fE = M - Ek + e*sin(Ek);
    fpE = -1 + e*cos(Ek);
    Ekp1 = Ek - fE/fpE;
%     fprintf('%12.8f  %12.8f\n',Ek, Ekp1);
    if abs(Ekp1 - Ek) < eps
        break;
    end
    Ek = Ekp1;
end
