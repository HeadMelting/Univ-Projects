function [code_bias] = get_bias(bias_arr,prn,obstype,gs)
    code_bias = 0;
    unique_gbias_gs = unique(bias_arr(:,1));
    valid_nums_gbias = unique_gbias_gs(unique_gbias_gs <= gs);
    closest_gs_gbias = max(valid_nums_gbias);
    
    bias = bias_arr(bias_arr(:,1) == closest_gs_gbias,:);

    bias_line = bias(bias(:,3) == prn,:);
    bias_line = bias_line(4:end);
    idx = find(bias_line == obstype);
    if ~isempty(idx)
        code_bias = bias_line(idx+1);
    end
    
end

