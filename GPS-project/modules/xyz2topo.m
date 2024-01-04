function [dNEV] = xyz2topo(dXYZs, phi, lamda)
%XYZ2TOPO 이 함수의 요약 설명 위치
%   자세한 설명 위치

dNEV=zeros(size(dXYZs,1),3);

for i=1:size(dXYZs,1)

    dXYZ = dXYZs(i,:)';

    A=[ -sind(lamda)            cosd(lamda)              0;    
        -sind(phi)*cosd(lamda)   -sind(phi)*sind(lamda)   cosd(phi);
        cosd(phi)*cosd(lamda)   cosd(phi)*sind(lamda)    sind(phi)];

    dENV =(A*dXYZ)';

    dNEV(i,:) = [dENV(2),dENV(1),dENV(3)];
    
end