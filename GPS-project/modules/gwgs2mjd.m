function [mjd] = gwgs2mjd(gw, gs)
% Convert GPS week number and GPS week second to Modified Julian Date (MJD)

% GPS time epoch starts from January 6, 1980 (MJD 44244)
gps_epoch_mjd = 44244;

% Convert GPS week number and GPS week second to GPS time in seconds
gps_time_sec = gw * 7 * 86400 + gs;

% Convert GPS time to UTC time in seconds
utc_time_sec = gps_time_sec - 18;

% Convert UTC time to MJD
mjd = (utc_time_sec / 86400) + gps_epoch_mjd;

end