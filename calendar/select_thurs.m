function this=select_thurs

day_week=weekday(now);

switch day_week
    case 1
        this=now-3;
    case 2
        this=now-4;
    case 3
        this=now-5;
    case 4
        this=now-6;
    case 5
        this=now;
    case 6
        this=now-1;        
    case 7
        this=now-2;        
end