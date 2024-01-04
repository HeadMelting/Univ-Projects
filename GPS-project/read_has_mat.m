function  [orbit, clock, g_bias, e_bias]= read_has_mat(gw,gs)
MOUNT = 'SSRA00EUH0';
disp(gs);

[year,month,dd,hh,~] = gwgs2date(gw,gs);

doy = datenum(year,month,dd) - datenum(year,1,1) + 1;
year_str = num2str(year);
year_char = year_str(end-1:end);
time_char = char('A' + hh);

mat_path = sprintf('datasets/mat/%s%03d%s.%sC.mat',MOUNT,doy,time_char,year_char);    
disp(mat_path)
if ~exist(mat_path,'file')
    fprintf('해당 파일이 존재하지 않습니다 : %s',mat_path)
    return;
end

mat = load(mat_path);
%% Clock
clock = mat.clock;

%% ORBIT
orbit = mat.orbit;

% %% Bias_G
g_bias = mat.code_g;
% unique_gbias_gs = unique(mat.code_g(:,1));
% valid_nums_gbias = unique_gbias_gs(unique_gbias_gs <= gs);
% closest_gs_gbias = max(valid_nums_gbias);
% 
% closest_idx_gbias = find(mat.code_g(:,1) == closest_gs_gbias);
% g_bias = mat.code_g(closest_idx_gbias,:);
%% Bias_E
% unique_ebias_gs = unique(mat.code_e(:,1));
% valid_nums_ebias = unique_ebias_gs(unique_ebias_gs <= gs);
% closest_gs_ebias = max(valid_nums_ebias);
% 
% closest_idx_ebias = find(mat.code_e(:,1) == closest_gs_ebias);
% e_bias=mat.code_e(closest_idx_ebias,:);
% e_bias = mat.code_e(closest_idx_ebias);
e_bias = mat.code_e;
end

