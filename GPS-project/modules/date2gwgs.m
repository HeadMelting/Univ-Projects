function [gw, gs]=date2gwgs(year, month, day, hh, mm, ss)

if month<=2 % 날짜변환 조건식 month가 2보다 작은경우

year=year-1; %year에서 1을 빼주고

month=month+12; %month에서 12를 더해준다.

else

year=year;

month=month;

end



% 날짜변환식에 따라 원하는 날짜를 JD로 바꾼다.

JD=floor(365.25*year)+floor(30.6001*(month+1))+day+(hh+mm/60+ss/3600)/24+1720981.5;

% mjd = JD - 2400000.5;
% fprintf('mjd: %12.2f',mjd);

jj=2444244.5; %jj= 1980년 1월 6일의 JD이다.

gw=floor((JD-jj)/7); % GPS Week Number 계산 과정



% 구한 JD를 대입하여 원하는 날짜의 요일을 구한다.

n = mod(floor(JD+0.5),7);

%n=6 일 때, GPS Week Day=0

%n=0~5일 때, GPS Week Day=n+1

% gs= GPS Week Seconds = 86400*GPS Week Day + hh*3600 + mm*60 + ss



if n==6 %요일에 따른 GPS Week Seconds 계산 과정

gs=hh*3600+mm*60+ss;

else

n=n+1; % n=GPS Week Day

gs=86400*n+hh*3600+mm*60+ss;

end

% fprintf(1, '결과: gw:%d gs:%d\n',gw,gs)