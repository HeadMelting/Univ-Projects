% clear; close all; clc;
addpath('modules/');

%% CONSTANTS
EPH_PATH = 'datasets/eph/BRDM00DLR_S_20231710000_01D_MN.rnx';
QM_PATH = 'datasets/qm/QM_GAMG00KOR_R_20231090000_01D_30S_MO';
GIM_PATH = 'c1pg1710.23i';

GS_RANGE = [234000 237590];

%% LOAD DATA
% eph = ReadEPH_multi(EPH_PATH);
QM_PATH_LISTS = {
'datasets/qm/QM_GAMG00KOR_R_20231711700_15M_01S_MO',...
'datasets/qm/QM_GAMG00KOR_R_20231711715_15M_01S_MO',...
'datasets/qm/QM_GAMG00KOR_R_20231711730_15M_01S_MO',...
'datasets/qm/QM_GAMG00KOR_R_20231711745_15M_01S_MO',...
};
arrQM = LoadQM(QM_PATH_LISTS);

[gw, gs_start] = date2gwgs(2023,6,20,17,0,0);

% 3405
%% GPS SPP
% [dNEVS_GPS_SPP,GPS_SPP_3D,GPS_SPP_H] = GPS_SPP(eph,GIM_PATH,GS_RANGE,arrQM,gw);


%% GPS HAS
% [dNEVS_GPS_HAS,GPS_HAS_3D,GPS_HAS_H] = GPS_HAS(eph,GIM_PATH,GS_RANGE,arrQM,gw, gs_start);

%% GAL SPP
% [dNEVS_GAL_SPP,GAL_SPP_3D,GAL_SPP_H] = GAL_SPP(eph,GIM_PATH,GS_RANGE,arrQM,gw);

%% GAL HAS
% [dNEVS_GAL_HAS,GAL_HAS_3D,GAL_HAS_H] = GAL_HAS(eph,GIM_PATH,GS_RANGE,arrQM,gw, gs_start);

%% GPS + GAL SPP
% [dNEVS_GPS_GAL_SPP,GPS_GAL_SPP_3D,GPS_GAL_SPP_H] = GPS_GAL_SPP(eph,GIM_PATH,GS_RANGE,arrQM,gw);

%% GPS + GAL + HAS
% [dNEVS_GPS_GAL_HAS,GPS_GAL_HAS_3D,GPS_GAL_HAS_H] = GPS_GAL_HAS(eph,GIM_PATH,GS_RANGE,arrQM,gw, gs_start);

figure(1)
x = dNEVS_GPS_GAL_HAS(:,1);
% Hours = mod(x,86400)/3600;1
Hours = mod(x,86400)/3600;
% GPS SPP
plot(dNEVS_GPS_SPP(:,2),dNEVS_GPS_SPP(:,3),'o');
% hold on;
% % GPS HAS
%  plot(Hours,GPS_HAS_3D);
% GAL SPP
% plot(Hours,GAL_SPP_H);
% hold on;
%  GAL HAS
% plot(Hours,GAL_HAS_H);
% % GPS _ GAL SPP
% plot(Hours,GPS_GAL_SPP_H);
% GPS GAL HAS
hold on;
plot(dNEVS_GPS_GAL_HAS(:,2),dNEVS_GPS_GAL_HAS(:,3),'o');
xline(0);
yline(0);
ylabel('E');
xlabel('N');
legend('GPS SPP','GPS GAL HAS');

figure(2)

plot(Hours,dNEVS_GPS_SPP(:,4));
hold on;
plot(Hours,dNEVS_GPS_GAL_HAS(:,4));
yline(0);
legend('GPS SPP','GPS GAL HAS');