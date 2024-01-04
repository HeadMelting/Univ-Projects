function [dIono] = Klobuchar(a, b, lat, lon, el, az, gs)
% Input
% a,b:α1~α4,β1~β4
% lat, lon: user%s position
% el, az: satellite%s elevation & azimuth angle (degree)
% gs: GPS Week Second
% Output
% dIono: Ionospheric Delay Error (m)

% 1 sc = 180dg = pi (Rad)

el_sc = el / 180;

%1. calculate Earth-centered Angled
phi = 0.0137 / (el_sc + 0.11) - 0.022; % semicircles

% 2. Compute the latitude of the Ionospheric Pierce Point (IPP)
ipp_lat = lat + phi*cosd(az); % semicircles

if ipp_lat > 0.416
    ipp_lat = 0.416;
elseif ipp_lat < -0.416
    ipp_lat = -0.416;
end

% 3. Compute the longitude of the IPP
ipp_lon = lon + (phi*sind(az))/cos(ipp_lat); % cos(semicircles) Might have to change degree

% 4. Find the geomagnetic latitude of the IPP.
ipp_lat_geo = ipp_lat + 0.064*cos(ipp_lon - 1.617); % cos(semicircles)

% 5. Find the local time at the IPP.
t = 43200*ipp_lon + gs;
if t >= 86400
    t = t - 86400;
elseif t < 0
    t = t + 86400;
end

% 6. Compute the amplitude of ionospheric delay.
A_id= a(1) + a(2)*ipp_lat_geo + a(3)*ipp_lat_geo^2 + a(4)*ipp_lat_geo^3;

if A_id < 0 
    A_id = 0;
end

% 7. Compute the period of ionospheric delay
P_id = b(1) + b(2)*ipp_lat_geo + b(3)*ipp_lat_geo^2 + b(4)*ipp_lat_geo^3;
if P_id < 7200
    P_id = 7200;
end

% 8. Compute the phase of ionospheric delay.
Phase_id = 2*pi*(t - 50400)/P_id; % rad

% 9. Compute the slant factor (elevation E in semicircles).
F = 1.0 + 16.0 * (0.53 - el_sc)^3;

% 10. Compute the ionospheric time delay
if abs(Phase_id) < 1.57
    I_L1 = (5*10^-9+A_id*(1 - Phase_id^2/2 + Phase_id^4/24))*F;
else
    I_L1 = 5*10^-9 * F;
end

dIono = I_L1 * 299792458;
