% Assigning latencies calculated by NS-2 to corresponding measurements
% z_latency_NS2 = [latency; measurement instrument type (1-RTU, 2-PMU)]
% Author: Vanja Svenda

function [z_latency_NS2,RTU_meas_cnt,PMU_meas_cnt]=...
    Latency_input(t_kk,opt0,zdata,RTU_meas_cnt,PMU_meas_cnt,time_iter)
% Calculated Measurement latencies by NS-2

global t_step_allign t_step_se
z_latency_NS2=zeros(size(zdata,1),2);

if opt0==1 % 14 Bus System   
    for i=1:size(zdata,1)
        if zdata(i,7)==2
            if t_kk+t_step_allign>=t_step_se % RTU is sent every 2 sec
                z_latency_NS2(i,1)=dlmread('Results_14_Bus_all_RTU.win.txt','',...
                    [RTU_meas_cnt zdata(i,8)-1 RTU_meas_cnt zdata(i,8)-1]);
            else
                z_latency_NS2(i,1)=0;
            end
            z_latency_NS2(i,2)=1; % RTU measurement
        elseif zdata(i,7)==1
%             % SLOW - PMU outage is taken into account
%             PMU_set=dlmread('Results_14_Bus_all_PMU.win.txt','',...
%                 [PMU_meas_cnt*50 zdata(i,8)-1 PMU_meas_cnt*50+48 zdata(i,8)-1]); 
%             if all(PMU_set==0)
%                 z_latency_NS2(i,1)=0;
%             else
%                 z_latency_NS2(i,1)=0.02;
%             end
            % FAST - PMU outage is not taken into account
            z_latency_NS2(i,1)=0.02; % some meas. will always be available (PMU buffering)
            z_latency_NS2(i,2)=2; % PMU measurement
        end

    end    
    PMU_meas_cnt=PMU_meas_cnt+1;
    if t_kk+t_step_allign>=t_step_se
        RTU_meas_cnt=RTU_meas_cnt+1;
    end
    
elseif opt0==2 % 300 Bus System
    for i=1:size(zdata,1)
        if zdata(i,7)==11
            if t_kk+t_step_allign>=2 % RTU is sent every 2 sec
                z_latency_NS2(i,1)=dlmread('Results_300_Bus_Area1_Part1_all.win.txt','',...
                    [RTU_meas_cnt zdata(i,8)-1 RTU_meas_cnt zdata(i,8)-1]); 
            else
                z_latency_NS2(i,1)=0;
            end
            z_latency_NS2(i,2)=1; % RTU measurement
        elseif zdata(i,7)==12
            if t_kk+t_step_allign>=2 % RTU is sent every 2 sec
                z_latency_NS2(i,1)=dlmread('Results_300_Bus_Area1_Part2_all.win.txt','',...
                    [RTU_meas_cnt zdata(i,8)-1 RTU_meas_cnt zdata(i,8)-1]); 
            else
                z_latency_NS2(i,1)=0;
            end
            z_latency_NS2(i,2)=1; % RTU measurement
        elseif zdata(i,7)==3
            if t_kk+t_step_allign>=2 % RTU is sent every 2 sec
                z_latency_NS2(i,1)=dlmread('Results_300_Bus_Area3_all.win.txt','',...
                    [RTU_meas_cnt zdata(i,8)-1 RTU_meas_cnt zdata(i,8)-1]); 
            else
                z_latency_NS2(i,1)=0;
            end
            z_latency_NS2(i,2)=1; % RTU measurement
        elseif zdata(i,7)==2
%             % SLOW - PMU outage can exist
%             PMU_set=dlmread('Results_300_Bus_Area2_all.win.txt','',...
%                 [PMU_meas_cnt*50 zdata(i,8)-1 PMU_meas_cnt*50+48 zdata(i,8)-1]); 
%             if all(PMU_set==0)
%                 z_latency_NS2(i,1)=0;
%             else
%                 z_latency_NS2(i,1)=0.02;
%             end
            % FAST - PMU outage cannot exist (it is not taken into account)
            z_latency_NS2(i,1)=0.02; % some meas. will always be available (PMU buffering)
            z_latency_NS2(i,2)=2; % PMU measurement
        end
    end
    if t_kk+t_step_allign>=2
        RTU_meas_cnt=RTU_meas_cnt+1;
    end
end     
    
end