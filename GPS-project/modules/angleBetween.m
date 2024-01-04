function [angle] = angleBetween(vec1, vec2)
%% 두 벡터의 사잇각을 구하는 함수
% input:    vec1, vec2
% output:   angle (double, degree)

%% calculate the dot product of v1 and v2
dot_product = dot(vec1, vec2);

%% calculate the magnitudes of v1 and v2
mag_v1 = norm(vec1);
mag_v2 = norm(vec2);

%% calculate the angle between v1 and v2 in radians
angle_rad = acos(dot_product / (mag_v1 * mag_v2));

% angle_rad = min(pi - angle_rad,angle_rad);

%% convert the angle to degrees
angle_deg = angle_rad * 180 / pi;

angle = angle_deg;

end