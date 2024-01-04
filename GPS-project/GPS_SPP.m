function [dNEVs,Error_3D,Error_H] = GPS_SPP(eph,GIM_PATH,GS_RANGE,arrQM,gw)
addpath('modules/')
%% CONSTANTS
obsType = 103;
TruePos = [-3191608.018 4096899.771 3691839.186]; % 감악산
CCC = 299792458;

TrueLLh = xyz2gd(TruePos);
TrueLat = TrueLLh(1);
TrueLon = TrueLLh(2);

%% Read Files
% GIM
[Lat, Lon, TEC] = ReadGIM2(GIM_PATH);


%% QM 선별
FinalTTs = unique(arrQM(:,1));
FinalTTs = FinalTTs(FinalTTs(:,1) >= GS_RANGE(1) & FinalTTs(:,1) <= GS_RANGE(2));

%% 추정에 필요한 반복 조건 및 초기값 설정
MaxIter = 15;
EpsStop = 1e-5;
x = [TruePos 1]; x = x';


%% Estimation
NoEpochs = length(FinalTTs);
nEst = 0;
estm = zeros(NoEpochs, 5);

for ke = 1:NoEpochs
    gs = FinalTTs(ke);
    idx1e = find(arrQM(:,1) == gs & arrQM(:,3) == obsType & arrQM(:,2) > 100 & arrQM(:,2) < 200 );
    QM1e = arrQM(idx1e,:);
    NoSats = height(QM1e);
    clc;
    fprintf('GPS_SPP : epoch:\r%d/%d\n',ke,NoEpochs);
    
    % 포지셔닝 최소자승 
    for k1 = 1:MaxIter
        
        HTH = zeros(4,4);
        HTy = zeros(4,1);
        vec_site = x(1:3)';
        
        % for all Sats in 1 epoch
        for kS = 1:NoSats
            prn = QM1e(kS,2);
            ieph = PickEPH(eph, prn, gs);
            toe = eph(ieph,1);
            obs = QM1e(kS,4);

            if eph(ieph, 19) ~= 0
                continue;
            end
        
            % 신호 전달 시간 고려
%             tc = calSTT(gs,vec_site,eph,ieph);
%             STT = gs - tc;
            STT = obs/CCC;
            tc = gs - STT;

            [vec_sat,vel_sat,~] = getSatPosVel_glo(eph, ieph, tc);

            % 지구 자전 고려
            vec_sat = RotSatPos(vec_sat, STT);

            % Rho Vector
            vec_rho = vec_sat - vec_site;
            rho = norm(vec_rho);

            %% 위성 시계오차 모델링
            a = eph(ieph,3);
            b = eph(ieph,4);
            c = eph(ieph,5);
        
            %% SPP CLOCK Correction 상대성
%             dtRel = -4.442807633e-10 * eph(ieph,11) * eph(ieph,10) * sin(Ek);
            dtRel = (-2 * dot(vec_sat,vel_sat)) / (CCC*CCC);
            
            % Group Delay
            tgd = eph(ieph,6);

            dtSat = a + b*(tc - toe) + c*(tc - toe)^2 + dtRel - tgd;
            
            %% Topo
            vec_site_gd = xyz2gd(vec_site);
%             vec_rho_topo = xyz2topo(vec_rho,vec_site_gd(1),vec_site_gd(2));
            vec_rho_topo = xyz2topo(vec_rho,vec_site_gd(1),vec_site_gd(2));
            N = vec_rho_topo(1);
            E = vec_rho_topo(2);
            
%             el = atand(V/norm(vec_rho_topo));
            el = acosd(norm([N,E,0])/norm(vec_rho_topo));
            
            %% Weight
            w = sind(el);
            if el < 10
                w=0;
            end
            %% GIM - Iono
            STEC = GIM2(Lat,Lon,TEC,vec_sat,vec_site,el,gs);

            dIono = STEC*0.162372;
            
            %% Tropo
            ZHD = TropGPTh(vec_site,gw,gs);
            dTrop = ZHD2SHD(gw,gs,vec_site,el,ZHD);
             
            com = rho + x(4)  - CCC*dtSat + dIono + dTrop;

            %% H - Matrix
            y = obs - com;
            H(1,1) = -vec_rho(1)/rho;
            H(1,2) = -vec_rho(2)/rho;
            H(1,3) = -vec_rho(3)/rho;
            H(1,4) = 1;

            HTH = HTH + H'*w*H;
            HTy = HTy + H'*w*y;
            
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

    
    dNEVs(ke,1) = estm(ke,1);
    dNEV = xyz2topo(estm(ke, 2:4)-TruePos, TrueLat, TrueLon);
    dNEVs(ke, 2:4) = dNEV;
    Error_3D(ke) = norm(dNEV);
    Error_H(ke) = norm(dNEV(1:2));
end

estimation_failure = estm(:,2) == 0;
estm(estimation_failure,:) = [];
dNEVs(estimation_failure,:) = [];
n = length(estm);
x_RMSE = sqrt(sum((estm(:,2) - TruePos(1)).^2)/n);
y_RMSE = sqrt(sum((estm(:,3) - TruePos(2)).^2)/n);
z_RMSE = sqrt(sum((estm(:,4) - TruePos(3)).^2)/n);
n_RMSE = sqrt(sum(dNEVs(:,2).^2)/n);
e_RMSE = sqrt(sum(dNEVs(:,3).^2)/n);
v_RMSE = sqrt(sum(dNEVs(:,4).^2)/n);
td_RMSE = sqrt(sum(Error_3D.^2)/n);
fprintf('MEAN : %2.3f %2.2f %2.3f\n',mean(estm(:,2))-TruePos(1),mean(estm(:,3))-TruePos(2),mean(estm(:,4))-TruePos(3))
fprintf('RMSE : X %2.3f Y %2.2f Z %2.3f\n',x_RMSE,y_RMSE,z_RMSE);
fprintf('RMSE : N %2.3f E %2.2f V %2.3f 3D %2.3f\n',n_RMSE,e_RMSE,v_RMSE,td_RMSE);

end
