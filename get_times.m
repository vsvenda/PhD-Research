% get_times
% get actual times
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

% start_time - sec, step - sec
function day_time=get_times(start_time,number_of_steps)

global t_step_allign

step_count=1;
for i=start_time:t_step_allign:(start_time+number_of_steps*t_step_allign)
    hour=rem(floor(i./3600),24);
    min=floor((i-floor(i./3600)*3600)./60);
    sec=i-floor(i./3600)* 3600-min*60;
    time=[hour min sec];
    day_time(step_count,:)=time;
    step_count=step_count+1;
end
