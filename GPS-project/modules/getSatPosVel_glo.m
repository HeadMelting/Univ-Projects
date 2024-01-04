function [SatPos,Vel,Ek] = getSatPosVel_glo(eph,ieph,t)
[SatPos,Ek] = getSatPos_glo(eph,ieph,t);
[NextSatPos,~] = getSatPos_glo(eph,ieph,t+0.001);
Vel = (NextSatPos - SatPos)/0.001;

end

