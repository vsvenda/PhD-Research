% denote_outage
% Denotes various outages in certain elements and at certain times
% -- load outage via busdata
% -- generator outage via busdata
% -- line outage via linedata
% -- measurement outage via m_outage
% --unobservable states via unobs_ind
% Authors: Vanja Svenda and Alex Stankovic

function [unobs_ind,Ybus,m_outage] = denote_outage(time_iter,Ybus,unobs_ind,m_outage,opt6)

global busdata linedata

% Parameter initialization
% Load outage
load_denote=0;              % (0 - no; 1 - yes)
load_bus=[];                % load buses
load_start=0; load_end=500; % start/end times

% Generator outage
gen_denote=0;               % (0 - no; 1 - yes)
gen_bus=[];                 % generator buses
gen_start=0; gen_end=3600;  % start/end times

% Line outage
line_denote=0;              % (0 - no; 1 - yes)
line_bus=[];                % line buses
line_start=0; line_end=3600;% start/end times

% Measurement outage
meas_denote=0;              % (0 - no; 1 - yes)
m_outage_indx=[];           % affectred measurements
m_outage_indx=sort(m_outage_indx);
meas_start=0; meas_end=3600;% start/end times

% Unobservable states
unobs_denote=0;                 % (0 - no; 1 - yes)
unobs_st=[];                    % unobservable state
unobs_st=sort(unobs_st);
unobs_start=0; unobs_end=3600;  % start/end times

% Execution
if load_denote % load
    if time_iter>=load_start && time_iter<=load_end % Time interval of load outage
        for i=1:length(load_bus)
            busdata(load_bus(i),5)=0;
            busdata(load_bus(i),6)=0;
        end
    end
end

if gen_denote % generator
    if time_iter>=gen_start && time_iter<=gen_end % Time interval of generator outage
        for i=1:length(load_bus)
            busdata(gen_bus(i),7)=0;
            busdata(gen_bus(i),8)=0;
            busdata(gen_bus(i),2)=0;
        end
    end
end

if line_denote % line
    if time_iter>=line_start && time_iter<=line_end % Time interval of line outage
        for i=1:size(line_bus,1)
            find_ind=and(any(linedata(:,1:2) == line_bus(i,1),2), any(linedata(:,1:2) == line_bus(i,2),2));
            find_ind=find(find_ind,1);
            linedata(find_ind,3)=1e+6;
        end
        [Ybus]=lf_ybus();
    end
end

if meas_denote % measurement
    if time_iter>=meas_start && time_iter<=meas_end % Time interval of unobservable states
        for i=1:length(m_outage_indx)
            m_outage(m_outage_indx(i))=1;
        end
    end
end

if unobs_denote % unobservable states
    if time_iter>=unobs_start && time_iter<=unobs_end % Time interval of unobservable states
        unobs_ind=unobs_st-opt6;
    end
end

end

