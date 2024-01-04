function [RotSatPos] = RotSatPos(SatPos,STT)
ome_e = 7.29e-5;
rota = ome_e * STT;
R_e = [cos(rota) sin(rota) 0; -sin(rota) cos(rota) 0; 0 0 1];
RotSatPos = R_e * SatPos';
RotSatPos = RotSatPos';