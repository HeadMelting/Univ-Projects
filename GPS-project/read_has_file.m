function [orbit,clock,code_e,code_g] = read_has_file(HAS_file)

orbit = [];
clock = [];
code_e = [];
code_g = [];

fid_HAS = fopen(HAS_file, 'r');
while ~feof(fid_HAS)
    line = fgets(fid_HAS);
    if startsWith(line, '>')
                [type, gs, interval] = read_header(line);
    else
        if type == "ORBIT"
            save_orbit(line, gs, interval)
        elseif type == "CLOCK"
            save_clock(line, gs, interval)
        elseif type == "CODE_BIAS"
            save_code(line, gs, interval)
        end
    end
end


% unique
code_e = unique(code_e,'rows');
code_g = unique(code_g,'rows');
clock = unique(clock,'rows');
orbit = unique(orbit,'rows');

fclose(fid_HAS);

%% sub functions

%% read_header
     function [type,gs,interval]=read_header(header)
            s_line = strsplit(header,' ');
            
            type = s_line{1,2};
            year = str2double(s_line{1,3});
            month = str2double(s_line{1,4});
            dd = str2double(s_line{1,5});
            hh = str2double(s_line{1,6});
            mm = str2double(s_line{1,7});
            ss = str2double(s_line{1,8});
            interval = str2double(s_line{1,9});
            
            [~,utc] = date2gwgs(year,month,dd,hh,mm,ss);
            gs = utc + 18;
     end

%% CODE_BIAS
    function save_code(line,gs_in,interval_in)
        s_line = strsplit(line," ");
        add = zeros(1,length(s_line)+1);
       
        
        % gs
        add(1) = gs_in;
        % type - interval
        add(2) = interval_in;
        % prn
        if strcmp(line(1),'G')
            add(3) = str2double(s_line{1}(2:3)) + 100;
        else 
            add(3) = str2double(s_line{1}(2:3)) + 400;
        end
        
    
        if startsWith(line,"G")
            for k = 3:2:length(s_line)
                phase_type = s_line{1,k};
                corr = str2double(s_line{1,k+1});
                switch phase_type
                    case "1C"
                        add(k+1) = 103;
                        
                    case "2L"
                        add(k+1) = 212;
                        
                    case "2P"
                        add(k+1) = 216;
                       
                end
             
             add(k+2) = corr;
            end
            code_g(end+1,1:length(add)) = add;
            
        elseif startsWith(line,"E")
            for k = 3:2:length(s_line)
                phase_type = s_line{1,k};
                corr = str2double(s_line{1,k+1});
                switch phase_type
                    case "1C"
                        add(k+1) = 103;
                        
                    case "5Q"
                        add(k+1) = 517;
                        
                    case "7Q"
                        add(k+1) = 717;
                    case "6C"
                        add(k+1) = 603;
                end
             
             add(k+2) = corr;
            end
            code_e(end+1,1:length(add)) = add;
            
        end
    end

%% ORBIT
    function save_orbit(line,gs_in,interval_in)
        % PRN, DES, N, T, W, N_dot, T_dot, W_dot
        s_line = strsplit(line," ");
        add = zeros(1,length(s_line)+2);
        % gs
        add(1) = gs_in;
        % type - interval
        add(2) = interval_in;
        % prn
        if strcmp(line(1),'G')
            add(3) = str2double(s_line{1}(2:3)) + 100;
        else 
            add(3) = str2double(s_line{1}(2:3)) + 400;
        end
        
        s_double = str2double(s_line);
        add(4:end) = s_double(2:end);
        orbit(end+1,1:length(add)) = add;
       
    end

%% CLOCK
    function save_clock(line,gs_in,interval_in)
        % PRN, DES, c0 c1 c2
        s_line = strsplit(line,' ');
        add = zeros(1,length(s_line)+2);
         % gs
        add(1) = gs_in;
        % type - interval
        add(2) = interval_in;
        % prn
        if strcmp(line(1),'G')
            add(3) = str2double(s_line{1}(2:3)) + 100;
        else 
            add(3) = str2double(s_line{1}(2:3)) + 400;
        end
        
        s_double = str2double(s_line);
        add(4:end) = s_double(2:end);
        clock(end+1,1:length(add)) = add;
        
    end
end

