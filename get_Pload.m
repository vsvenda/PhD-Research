% get_Pload
% Get actual active power load
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function P=get_Pload(loadCurve,timeSequence,hour,min,sec,opt3)

if (hour<0 || hour>24), hour=0; end
if (min<0 || min>60),   min=0;  end
if (sec<0 || sec>60),   sec=0;  end

time=hour*60*60+min*60+sec;
if time>86400,  time=min*60+sec; end

if opt3==1
    P=interp1(timeSequence,loadCurve,time);
elseif opt3==2
    ii=find(timeSequence<=time);
    ii=max(ii); 
    tg=(loadCurve(ii(1)+1)-loadCurve(ii(1)))/(timeSequence(ii(1)+1)-timeSequence(ii(1)));
    P=loadCurve(ii(1))+tg*(time-timeSequence(ii(1)));
end
