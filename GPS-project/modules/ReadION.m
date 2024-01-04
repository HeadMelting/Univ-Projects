function [alpha,beta] = ReadION(file)
fileID = fopen(file,'r');
textscan(fileID, '%s',24);
alpha_data = textscan(fileID, '%f %f %f %f',4);
textscan(fileID, '%s',2);
beta_data = textscan(fileID, '%f %f %f %f',4);

fclose(fileID);

alpha = [alpha_data{1},alpha_data{2},alpha_data{3},alpha_data{4}];
beta = [beta_data{1},beta_data{2},beta_data{3},beta_data{4}];

end

