%% FILE PATH
HAS_FILE_PATH = 'datasets/has/';
MAT_FILE_PATH = 'datasets/mat/';

if ~exist(HAS_FILE_PATH,'dir')
    disp('datasets/has 경로가 존재하지 않습니다.');
    disp('모든 HAS 데이터 파일은 datasets/has 경로에 넣어주십시오.')
    return;
end

all_list = dir(HAS_FILE_PATH);
file_names={};
for j=1:numel(all_list)
   if ~all_list(j).isdir
        file_names{end+1} = all_list(j).name;
    end
end

if ~exist(MAT_FILE_PATH,'dir')
    mkdir(MAT_FILE_PATH);
end
for i = 1:length(file_names)
    path = strcat(HAS_FILE_PATH,file_names{i});
    [orbit,clock,code_e,code_g] = read_has_file(path);
    mat_name = sprintf('%s%s.mat',MAT_FILE_PATH,file_names{i});
    save(mat_name,'orbit','clock','code_g','code_e');
    clear orbit clock code_e code_g;
end
