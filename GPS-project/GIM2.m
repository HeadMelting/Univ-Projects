function [STEC] = GIM2(Lat,Lon,TEC,vec_sat, vec_site,el, gs)

valTEC = TEC(2:end, 2:end, :);

%% IPP 계산
H = 450 * 1000; 
R_E = 6378137;
% Z = angleBetween(vec_site, vec_sat - vec_site);
Z = 90 - el;
Zp = asind(R_E * sind(180 - Z) / (R_E + H));

ipp_range = sqrt(R_E^2 + (R_E + H)^2 - 2*R_E*(R_E+H)*cosd(Z-Zp));
vec_rho = vec_sat - vec_site;
vec_rho_unit = vec_rho/norm(vec_rho);
vec_site_ipp = ipp_range * vec_rho_unit;
vec_ipp = vec_site + vec_site_ipp;

%% 시간보간
gs_list = TEC(1,1,:);
if gs < gs_list(1); gs = gs_list(1); end
if gs > gs_list(length(gs_list)); gs = gs_list(length(gs_list)); end 

if ismember(gs, gs_list)
    selValTEC = valTEC(:,:,gs == gs_list);
else
   diff = abs(gs_list - gs);
   [sort_diff, idx] = sort(diff);
   min_diff_gs = gs_list(idx(1:2));
   d1 = sort_diff(1);
   d2 = sort_diff(2);
   w1 = d2/(d1+d2);
   w2 = d1/(d1+d2);
   gs1 = min_diff_gs(1);
   gs2 = min_diff_gs(2);
   v1 = valTEC(:,:,gs1 == gs_list);
   v2 = valTEC(:,:,gs2 == gs_list);

   selValTEC = w1 * v1 + w2 * v2;

end

%% 공간보간
gd = xyz2gd(vec_ipp);
lat_ipp = gd(1); lon_ipp = gd(2);
dlat = abs(Lat - lat_ipp);
[dlat,lat_idx] = sort(dlat);
lat_idx = lat_idx(1:2);
w_lat = (1-dlat(1:2)/sum(dlat(1:2)));

dlon = abs(Lon - lon_ipp);
[dlon,lon_idx] = sort(dlon);
lon_idx = lon_idx(1:2);
w_lon = (1-dlon(1:2)/sum(dlon(1:2)));

VTEC = 0;

for i_lat = 1 : 2
    for i_lon = 1:2
        addition = w_lat(i_lat)*w_lon(i_lon)*selValTEC(lat_idx(i_lat),lon_idx(i_lon));
        VTEC = VTEC + addition;
    end
end

%% VTEC -> STEC
OF = 1 / cosd(Zp);  % oF
STEC = OF * VTEC;

end