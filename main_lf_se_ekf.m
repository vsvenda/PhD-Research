% main_lf_se_ekf
% Main program for:
% Load Flow (LF), Static State Estimation (SE)
% Probabilistic models for SE calculations
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

global busdata linedata t_step_scada t_step_allign t_step_se current_sec

options;

system_initialization(in_file1);
[Ybus]=lf_ybus();     % Ybus matrix

Ybus_SE=Ybus;         % Ybus matrix used for SE
linedata_SE=linedata; % linedata used for SE

busdata_initial=busdata; % initial bus data
day_time=get_times(start_time,number_of_steps); % time at each step of simulation

if opt3==1
    load_curves;    % Load/generation active power curves (24 points)
elseif opt3==2
    load_curves_1;  % Load/generation active power curves (much more points)
end

% Initializing used data sets
% PF    -- power flow
% SSE   -- static state estimation
if opt0==1
    V_all_PF=zeros(14,length(day_time(:,1))-1);  theta_all_PF=zeros(14,length(day_time(:,1))-1);
    V_all_SSE=zeros(14,length(day_time(:,1))-1); theta_all_SSE=zeros(14,length(day_time(:,1))-1);
    t_all=zeros(1,length(day_time(:,1))-1);
elseif opt0==2
    V_all_PF=zeros(300,length(day_time(:,1))-1);  theta_all_PF=zeros(300,length(day_time(:,1))-1);
    V_all_SSE=zeros(300,length(day_time(:,1))-1); theta_all_SSE=zeros(300,length(day_time(:,1))-1);
    t_all=zeros(1,length(day_time(:,1))-1);
elseif opt0==3
    V_all_PF=zeros(2746,length(day_time(:,1))-1);  theta_all_PF=zeros(2746,length(day_time(:,1))-1);
    V_all_SSE=zeros(2746,length(day_time(:,1))-1); theta_all_SSE=zeros(2746,length(day_time(:,1))-1);
    t_all=zeros(1,length(day_time(:,1))-1);
end

SE_available=zeros(length(day_time(:,1))-1,1); % SE availability at each time instant
unobs_ind=[]; % Initial indexes of unobservable states
convCnt=0; % convergence counter

RTU_meas_cnt=0;     % Used for forming the NS2 (RTU) measurement latency vector
PMU_meas_cnt=0;     % Used for forming the NS2 (PMU) measurement latency vector
t_kk=start_time-t_step_allign;
t_mm=start_time-t_step_allign;
recal_sen_matr=1;   % Recalculating sensitivity matrices needed?
recal_delta_t_se=0; % Recalculating optimal delta_t_se needed?

[pdf_travtime]=travel_times(opt0);         % Define prob. models of information transfer times
t_break=significance_test(pdf_travtime);   % Break time which defines meas. instr. outage (significance testing)
% pdf_travtime=ones(size(Ybus,1)); % use if probabilistic observability model is disregarded
% t_break=ones(size(Ybus,1),1);

for time_iter=1:(length(day_time(:,1))-1)
    clock1=day_time(time_iter,:);     % Time instant K
    clock2=day_time(time_iter+1,:);   % Time instant K+1
    current_sec=clock1(1)*3600+clock1(2)*60+clock1(3); % current time in seconds

    fprintf('\n\n  Hour: %3d  min: %3d  sec: %3d \n', clock1(1),clock1(2),clock1(3));

    % Update busdata with consumption/generation curves for current time
    [Pfactor]=update_bus_data(busdata_initial,loadCurve1,loadCurve2,loadCurve3,...
        loadCurve4,genCurveHydro,genCurveThermo,genCurveSolar,genCurveWind,...
        timeSequence1,clock1,clock2,opt3);
    Vm0=busdata(:,3); delta0=busdata(:,4);

    % Outage simulation
    if time_iter>1
        [unobs_ind,Ybus,m_outage]=denote_outage(time_iter,Ybus,unobs_ind,m_outage,opt6);
    end

    % Power flow and line flow calculations for current time step
    [J,dP,X,ns,nss]=lf_Newton(Vm0,delta0,Pfactor,Ybus,accuracy_PF,maxiter_PF,opt4);
    [nbrr,kbr,SnkPrel,SnkQrel,InkMrel]=line_flow(opt1);
    V_all_PF(:,time_iter)=busdata(:,3);
    theta_all_PF(:,time_iter)=busdata(:,4);
    % Create measurement matrix
    [zdata,MeasCov]=create_measurement_matrix(nbrr,kbr,SnkPrel,...
        SnkQrel,InkMrel,measVariance,pdf_travtime,t_break,opt6);

    % Calculation of telecommunication delays, packet drops and packet loss probabilities
    [z_latency_NS2,RTU_meas_cnt,PMU_meas_cnt]=...
        Latency_input(t_kk,opt0,zdata,RTU_meas_cnt,PMU_meas_cnt,time_iter); % Latency input from NS2
    zdata=[zdata z_latency_NS2]; % adding latency to measurements zdata(:,12) - latency; zdata(:,13) - meas. instr. type
    if time_iter==1
        m_outage=zeros(size(zdata,1),1); % no instrument outage at first
    end
    zdata=[zdata m_outage]; % adding meas. instrument outage indicator zdata(:,14)

    % Initial optimal delta_t_se
    if time_iter==1
        [nr_mset,delta_time,delta_perc]=observability_gram(zdata,Ybus,opt6);
        t_step_se=delta_time;
    end

    if time_iter==1
        BD_cnt=zeros(size(zdata,1),1);  % Bad Data counter
        miss_meas_cnt=zeros(size(zdata,1),1); % Missing measurements counter (delayed, dropped, bad data, outage)
        t_all(1)=start_time;
        % Initial moment state values are set to PF results for all SE models
        V_all_SSE(:,1)=busdata(:,3);    theta_all_SSE(:,1)=busdata(:,4);
        z_previous=zeros(size(zdata,1),size(zdata,2)); % zdata from previous time instance initialy 0
    end

    z_p=zdata; % zdata of this time instant (needed for measurement supplementing)
    % Measurements supplementing by previous time instance
    for kk=size(zdata,1):-1:1 % Measurements supplementing by previous time instance
        if (zdata(kk,12)>=t_step_allign || zdata(kk,12)==0 || zdata(kk,12)==-1 || zdata(kk,14)==1)&&...
                (z_previous(kk,12)<=(t_step_allign*2) && z_previous(kk,12)~=0 && z_previous(kk,12)~=-1 && z_previous(kk,14)~=1)
            for ii=1:size(zdata,2)
                zdata(kk,ii)=z_previous(kk,ii);
            end
            zdata(kk,12)=0.01; % set to a low value, this meas. will definitely be available
        end
    end

    if recal_sen_matr==1 % Recalculate sensitivity matrices via state_estimation()
        [F]=F_matrix(J,dP,X,ns,nss);
        [H,Vm_SSE,del_SSE,E]=state_estimation(linedata_SE,zdata,Ybus_SE,accuracy_SE,2,1,convCnt,opt6);
        recal_sen_matr=0;
    end
    t_mm=t_mm+t_step_allign;
    t_kk=t_kk+t_step_allign;
    if time_iter>1
        if t_mm>=t_step_scada % SCADA refresh
            recal_sen_matr=1;
            t_mm=0;
        end

        if t_kk>=t_step_se % SE refresh
            for kk=size(zdata,1):-1:1 % missing meas. counter
                if (zdata(kk,12)>=t_step_se || zdata(kk,12)==0 || zdata(kk,12)==-1 || zdata(kk,14)==1)
                    miss_meas_cnt(kk)=miss_meas_cnt(kk)+1;
                end
            end
            % Static State Estimation (SSE)
            t_kk=0;
            X_start=[theta_all_SSE(1+opt6:end,time_iter-1); V_all_SSE(:,time_iter-1)];
            [H,Vm_SSE,del_SSE,E,obs_check,H_reduced,Gm_reduced,Ri_reduced,...
                zdata_reduced,h_reduced,kept_measurements,convCnt,residual]=...
                state_estimation(linedata_SE,zdata,Ybus_SE,accuracy_SE,...
                maxiter_SE,0,convCnt,opt6,X_start,unobs_ind);
            if obs_check==0    % Network unobservable
                line_flow_se(Ybus,opt1);
                V_all_SSE(:,time_iter)=V_all_SSE(:,time_iter-1);
                theta_all_SSE(:,time_iter)=theta_all_SSE(:,time_iter-1);
            else                % Network observable
                V_all_SSE(:,time_iter)=Vm_SSE; theta_all_SSE(:,time_iter)=del_SSE;  
            end
        else
            V_all_SSE(:,time_iter)=V_all_SSE(:,time_iter-1);  
            theta_all_SSE(:,time_iter)=theta_all_SSE(:,time_iter-1);
        end
        t_all(time_iter)=time_iter*t_step_allign;
    end
    if time_iter==1
        update_X=E; update_P=(1e-4*diag(ones(length(E),1)));
    end
    z_previous=z_p; % Saved zdata for next time instance
end
fprintf (' \n\n ');
save('outputsMBAM.mat','t_all','V_all_PF','V_all_SSE','theta_all_PF'...
    ,'theta_all_SSE','zdata','Ybus');
