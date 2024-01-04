function [STEC] = GIM(Lat, Lon, TEC, vec_sat, vec_site, gs)
%% GIM Model을 이용해 이온층 오차 보정항을 계산하는 함수
% input:  Lat, Lon     <<< 수신기 위치
%         TEC          <<< TEC
%         vec_sat      <<< 위성의 3차원 좌표
%         vec_site     <<< 수신기의 3차원 좌표
%         gs           <<< 해당 시간
% output: dIono (double)

%% 데이터 선별
valTEC = TEC(2:end, 2:end, :);                  % TEC 값들만 추출 

%% IPP 계산
H = 450 * 1000;                                 % 이온층 높이(m)
%R_E = norm(vec_site);                           % 지구반지름(m)
R_E = 6378137;
Z = angleBetween(vec_site, vec_sat-vec_site);   % '천정_수신기-IPP' 사이각(degree)
sinZprime = sind(Z) * R_E / (R_E+H);            % sin(Z')
Zprime = asind(sinZprime);                      % Z'
range_SiteIPP = sqrt( R_E^2 + ...
    (R_E+H)^2 - 2*R_E*(R_E+H)*cosd(Z-Zprime) ); % 수신기-IPP 벡터 거리
vec_SiteIPP = range_SiteIPP * ...
    vec_sat / norm(vec_sat);                    % 수신기-IPP 벡터
% vec_rho = vec_sat - vec_site;
% vec_rho_unit = vec_rho/norm(vec_rho);
% vec_SiteIPP = range_SiteIPP * vec_rho_unit;
vec_IPP = vec_site + vec_SiteIPP;               % IPP 벡터

%% 시간 보간
time_all = 24;                                  % IONEX: 0~24h
time_interval = 2;                              % IONEX: 2h interval
time_list = 0:time_interval:time_all;           % 시간대 리스트 생성         
hour = gs / 86400 * 24;                         % 계산하려는 시간대의 단위변환(gs -> h_of_day)
if (hour<0);  hour= 0; end 
if (hour>24); hour=24; end

if ismember(hour, time_list)                    % 계산하려는 시각이 time_list에 포함되어 있으면 보간 생략
    hidx = (hour/2)+1;
    selValTEC = valTEC(:, :, hidx);
else                                            % 계산하려는 시각이 time_list에 포함되지 않으면 보간 수행
    hidx1 = floor(hour/2) + 1;
    hidx2 = floor(hour/2) + 2;
    time_weight = [abs(time_list(hidx1)-hour)^-1, ...
        abs(time_list(hidx2)-hour)^-1];        
    time_weight = time_weight/sum(time_weight); % 시간대 가중치 부여(선형)
    selValTEC = ...
        valTEC(:,:,hidx1) * time_weight(1) +  ...
        valTEC(:,:,hidx2) * time_weight(2);     % 시간 보간 수행(선형) 
end

%% VTEC 공간 보간
gd = xyz2gd(vec_IPP);
latIPP = gd(1); lonIPP = gd(2);                 % IPP의 경위도 좌표 추출

idx_lat = find(...
    Lat > latIPP-2.5 & Lat < latIPP+2.5);
idx_lon = find(...
    Lon > lonIPP-5.0 & Lon < lonIPP+5.0);
selValTEC = selValTEC(idx_lat, idx_lon);        % 보간에 이용할 데이터 선별 - 사각형 영역

finalTEC = zeros( size(selValTEC,1)*...
    size(selValTEC,2), 2 );                           % 각 컬럼이 위경도거리, TEC인 행렬 생성
idx = 1;
for row=1:size(selValTEC, 1)                          % 위의 행렬에 값 할당
    for col=1:size(selValTEC, 2)
        latTmp = Lat(idx_lat(row));
        lonTmp = Lon(idx_lon(col));
%         rangeTmp = norm([latTmp-latIPP, lonTmp-lonIPP]);
        rangeTmp = abs((latTmp-latIPP)*(lonTmp-lonIPP));
        TECTmp = selValTEC(row, col);
        finalTEC(idx, :) = [rangeTmp^-1 TECTmp]; 
        idx=idx+1;
    end
end
VTEC = dot( finalTEC(:,1), finalTEC(:,2)) /...
    sum(finalTEC(:,1) );                        % IDW를 적용한 TEC 값 계산

%% VTEC -> STEC
Zprime = asin(sinZprime);
OF = 1 / cos(Zprime);  % oF
STEC = OF * VTEC;


end