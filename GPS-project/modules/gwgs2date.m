function [year, month, day, hour, minute, second] = gwgs2date(gpsWeek, gpsSecond)
    % GPS Epoch (1980년 1월 6일 0시 0분 0초)을 datetime 형식으로 변환
    gpsEpoch = datetime(1980, 1, 6, 0, 0, 0);
    
    % GPS Week와 GPS Second을 datetime 형식으로 변환
    gpsDateTime = gpsEpoch + days(gpsWeek * 7) + seconds(gpsSecond);
    
 
    
    % datetime을 연도, 월, 일, 시간, 분, 초로 분리
    [year, month, day, hour, minute, second] = datevec(gpsDateTime);
end