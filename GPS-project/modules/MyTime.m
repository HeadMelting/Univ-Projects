classdef MyTime < handle
    %TIME_RAGE 이 클래스의 요약 설명 위치
    %   자세한 설명 위치
    properties
        gw_min
        gw_max
        gs_min
        gs_max
    end
    
    methods
        function obj = MyTime()
            obj.gs_max = -1;
            obj.gs_min = -1;
            obj.gw_max = -1;
            obj.gw_min = -1;
        end
        
        function obj = check_range(obj,input_gw,input_gs)
             if obj.gw_max == -1
                 obj.gw_max = input_gw;
                 obj.gs_max = input_gs;
                 obj.gs_min = input_gs;
                 obj.gw_min = input_gw;
             else
                 ctx_min = str2double(sprintf('%d%.0f',obj.gw_min,obj.gs_min));
                 ctx_max = str2double(sprintf('%d%.0f',obj.gw_max,obj.gs_max));
                 ctx_input = str2double(sprintf('%d%.0f',input_gw,input_gs));

                 if ctx_input < ctx_min
                     obj.gs_min = input_gs;
                     obj.gw_min = input_gw;
                 end

                 if ctx_input > ctx_max
                    obj.gw_max = input_gw;
                    obj.gs_max = input_gs;
                 end
             end
        end
        
        function range_str = show_range(obj)
            range_str = sprintf('%d,%.0f,%d,%.0f',obj.gw_min,obj.gs_min,obj.gw_max,obj.gs_max);
        end
        
    end
end

