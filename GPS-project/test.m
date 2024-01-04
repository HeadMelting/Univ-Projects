% clear; close all; clc;
addpath('modules/');
%% CONSTANTS
EPH_PATH = 'datasets/eph/BRDM00DLR_S_20231090000_01D_MN.rnx';
% QM_PATH = 'datasets/qm/QM_DAEJ00KOR_R_20231090000_01D_30S_MO';
QM_PATH = 'datasets/qm/QM_GAMG00KOR_R_20231090000_01D_30S_MO';
GIM_PATH = 'datasets/gim/jplg1090.23i';

obsType = 103;
TruePos = [-3191608.018 4096899.771 3691839.186]; % 가막
% TruePos = [-3120042.501 4084614.653 3764026.759];
CCC = 299792458;
TrueLLh = xyz2gd(TruePos);
TrueLat = TrueLLh(1);
TrueLon = TrueLLh(2);

%% Read Files
% EPH
% eph = ReadEPH_multi(EPH_PATH); % 주석 해제
% QM
arrQM = importdata(QM_PATH);
[Lat, Lon, TEC] = ReadGIM(GIM_PATH);

%% QM 선별
% GS_RANGE = [266000 267800];
GS_RANGE = [266382 267800];
FinalTTs = unique(arrQM(:,1));
FinalTTs = FinalTTs(FinalTTs(:,1) >= GS_RANGE(1) & FinalTTs(:,1) <= GS_RANGE(2));
%% 추정에 필요한 반복 조건 및 초기값 설정
MaxIter = 5;
EpsStop = 1e-5;
x = [TruePos 1]; x = x';
[gw, gs_start] = date2gwgs(2023,04,19,2,0,0);

%% 추정
NoEpochs = length(FinalTTs);
nEst = 0;
estm = zeros(NoEpochs, 5);


%% Load Has File
[orbit, clock, g_bias, e_bias]= read_has_mat(gw,gs_start);


for ke = 1:NoEpochs
    gs = FinalTTs(ke);
    idx1e = find(arrQM(:,1) == gs & arrQM(:,3) == obsType);
    QM1e = arrQM(idx1e,:);
    NoSats = length(QM1e);
    fprintf('epoch:\r%d/%d\n',ke,NoEpochs);
    
    % 포지셔닝 최소자승 
    for k1 = 1:MaxIter
        
        HTH = zeros(4,4);
        HTy = zeros(4,1);
        vec_site = x(1:3)';
%         RMSE : N 3.575 E 1.69 V 20.327
        % for all Sats in 1 epoch
        for kS = 1:NoSats
            prn = QM1e(kS,2);
            if prn > 500 || prn < 400
                continue;
            end
            ieph = PickEPH(eph, prn, gs);
            if isempty(ieph)
                continue;
            end
            toe = eph(ieph,1);

            IODE = eph(ieph,8);
            obs = QM1e(kS,4);
        
            % 신호 전달 시간 고려
            STT = obs/CCC;
            tc = gs - STT;

            [vec_sat,vel_sat,Ek] = getSatPosVel_glo(eph, ieph, tc);

            % 지구 자전 고려
            vec_sat = RotSatPos(vec_sat, STT);

%             %% Has - Orbit Correction
%             [dRs, dRs_dot,IODE_CHECK] = get_orbit(orbit,prn,gs,IODE);
%             if IODE_CHECK
%                 e_t = vel_sat/norm(vel_sat);
%                 e_w = cross(vec_sat,vel_sat)/norm(cross(vec_sat,vel_sat));
%                 e_n = cross(e_t,e_w);
%                 RotMat = [e_n' e_t' e_w'];
%                 dSatPose = RotMat * (dRs + dRs_dot*(tc-toe));
%                 vec_sat = vec_sat - dSatPose';
%                 
%             end
%            

            % Rho Vector
            vec_rho = vec_sat - vec_site;
            rho = norm(vec_rho);

            %% 위성 시계오차 모델링
            a = eph(ieph,3);
            b = eph(ieph,4);
            
%             %% HAS CLOCK Correction
%             [c0,c1,c2,IODE_CHECK] = get_clock(clock,prn,gs,IODE);
%             if IODE_CHECK
%                 dCs = c0 + c1*(gs-toe)+c2*(gs-toe)^2;
%                 dtrs = (-2 * dot(vec_sat,vel_sat)) / (CCC*CCC);
%                 dtSat = a + b*(gs-toe);
%                 dtSat = dtSat + dtrs - dCs/CCC;
%             else
%                 dtrs = (-2 * dot(vec_sat,vel_sat)) / (CCC*CCC);
%                 % Group Delay
%                 tgd = eph(ieph,6);
%                 dtSat = a + b*(gs - toe) + dtrs - tgd;
%      
%             end           
            %% SPP CLOCK Correction 상대성
            dtRel = -4.442807633e-10 * eph(ieph,11) * eph(ieph,10) * sin(Ek);

            % Group Delay
            tgd = eph(ieph,6);

            dtSat = a + b*(gs - toe) + dtRel - tgd;

            
            %% GIM - Iono
            STEC = GIM(Lat,Lon,TEC,vec_sat,vec_site,gs);
            dIono = STEC*0.162372;

            %% Tropo
            dTrop = getDT(vec_site,vec_rho,gw,gs);

            %% HAS Bias
%             bias = get_bias(e_bias, prn, obsType,gs);

            com = rho + x(4) - CCC*dtSat + dIono + dTrop ;%- bias;

            %% H - Matrix
            y = obs - com;
            H(1,1) = -vec_rho(1)/rho;
            H(1,2) = -vec_rho(2)/rho;
            H(1,3) = -vec_rho(3)/rho;
            H(1,4) = 1;

            HTH = HTH + H'*H;
            HTy = HTy + H'*y;
            
        end
        xhat = HTH\HTy;
        x = x + xhat;
        
        if norm(xhat) < EpsStop
            nEst = nEst + 1;
            estm(ke,1) = gs;
            estm(ke, 2:4) = x(1:3)';
            estm(ke,5) = x(4);
            break;
        end
        

    end

    
    nev(ke,1) = estm(ke,1);
    nev(ke, 2:4) = xyz2topo(estm(ke, 2:4)-TruePos, TrueLat, TrueLon);
end
% 
% 
estimation_failure = estm(:,2) == 0;
estm(estimation_failure,:) = [];
nev(estimation_failure,:) = [];
n = length(estm);
x_RMSE = sqrt(sum((estm(:,2) - TruePos(1)).^2)/n);
y_RMSE = sqrt(sum((estm(:,3) - TruePos(2)).^2)/n);
z_RMSE = sqrt(sum((estm(:,4) - TruePos(3)).^2)/n);
n_RMSE = sqrt(sum(nev(:,2).^2)/n);
e_RMSE = sqrt(sum(nev(:,3).^2)/n);
v_RMSE = sqrt(sum(nev(:,4).^2)/n);
fprintf('MEAN : %2.3f %2.2f %2.3f\n',mean(estm(:,2))-TruePos(1),mean(estm(:,3))-TruePos(2),mean(estm(:,4))-TruePos(3))
fprintf('RMSE : X %2.3f Y %2.2f Z %2.3f\n',x_RMSE,y_RMSE,z_RMSE);
fprintf('RMSE : N %2.3f E %2.2f V %2.3f\n',n_RMSE,e_RMSE,v_RMSE);


%% 가막 SPP GPS
% MEAN : -6.136 7.56 6.663
% RMSE : X 6.181 Y 7.60 Z 6.936
% RMSE : N 1.377 E 0.74 V 11.898
%% 가막 HAS GPS
% MEAN : -3.984 5.65 5.542
% RMSE : X 4.079 Y 5.71 Z 5.902
% RMSE : N 1.551 E 0.87 V 8.994
%% 가막 SPP GAL
% MEAN : -6.439 7.34 6.525
% RMSE : X 6.471 Y 7.41 Z 6.741
% RMSE : N 0.935 E 0.71 V 11.868
%% 가막 HAS GAL
% RMSE : X 6.323 Y 6.77 Z 4.964
% RMSE : N 1.473 E 0.93 V 10.362
