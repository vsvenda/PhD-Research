% create_measurement_matrix
% Create measurement matrix zdata which contains various measurement info.
% Measurement values are extracted from busdatam by adding measurements
% variance, instrument imperfection and noise to real values.
% zdata is formed as:
% column 1: meas. index
% column 2: meas. type
% column 3: meas. value
% column 4: sending node
% column 5: receiving node
% column 6: meas. variance
% column 7: area of meas.
% column 8: meas. index in its area
% column 9: meas. travel time mean
% column 10: meas. travel time variance
% column 11: break time for outage detection (added main, line 56-57)
% column 12: current time instant latency (added later in main, line ???)
% column 13: meas. instrument type (1 - RTU; 2 - PMU) (added later in main, line ???)
% column 14: meas. insturment outage indicator (1 - outage occured) (added later in main, line ???)
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [zdata,MeasCov]=create_measurement_matrix(nbrr,kbr,SnkPrel,...
    SnkQrel,InkMrel,measVariance,pdf_travtime,t_break,opt6)

global busdata basemva

nbus=length(busdata(:,1));
Vm=busdata(:,3);
delta=busdata(:,4);
Pd=busdata(:,5);
Qd=busdata(:,6);
Pg=busdata(:,7);
Qg=busdata(:,8);
Qsh=busdata(:,11);
Area=busdata(:,12);
NumArea=busdata(:,13);

Pn_inj=(Pg-Pd)./basemva;
Qn_inj=(Qg+Qsh-Qd)./basemva;

noise_var=1e-8;  % Noise variance
noise_mean=0;    % Noise mean

rng_opt=1;       % 0 - rng not seeded; 1 - rng seeded

zdata_cnt=1;     % Measurements counter

% Active power injection measurements
measType=2;
for n=[5 6 8 9 10 11 12 13 14]
    if rng_opt==1
        rng(0); % Seeding the random number generator
    end
    meas_var=abs(Pn_inj(n))*measVariance(measType); % Variance as value percentage
    instr_imp=sqrt(meas_var)*randn(1,1);            % instrument imperfection
    noise=noise_mean+sqrt(noise_var)*randn(1,1);    % noise
    MeasCov(zdata_cnt,zdata_cnt)=meas_var;
    zdata(zdata_cnt,:)=[zdata_cnt measType noise+instr_imp+Pn_inj(n) ...
        n 0 measVariance(measType) Area(n) NumArea(n) pdf_travtime(n,1) ...
        pdf_travtime(n,2) t_break(n)];
    zdata_cnt=zdata_cnt+1;
end

% Reactive power injection measurements
measType=3;
for n=[5 6 8 9 10 11 12 13 14]
    if rng_opt==1
        rng(0);
    end
    meas_var=abs(Qn_inj(n))*measVariance(measType); % Variance as value percentage
    instr_imp=sqrt(meas_var)*randn(1,1);            % instrument imperfection
    noise=noise_mean+sqrt(noise_var)*randn(1,1);    % noise
    MeasCov(zdata_cnt,zdata_cnt)=meas_var;
    zdata(zdata_cnt,:)=[zdata_cnt measType noise+instr_imp+Qn_inj(n) ...
        n 0 measVariance(measType) Area(n) NumArea(n) pdf_travtime(n,1) ...
        pdf_travtime(n,2) t_break(n)];
    zdata_cnt=zdata_cnt+1;
end

% Active power flow measurements
measType=4;
for n=[2 4 10 20]
    if rng_opt==1
        rng(0);
    end
    meas_var=abs(SnkPrel(n))*measVariance(measType); % Variance as value percentage
    instr_imp=sqrt(meas_var)*randn(1,1);             % instrument imperfection
    noise=noise_mean+sqrt(noise_var)*randn(1,1);     % noise
    MeasCov(zdata_cnt,zdata_cnt)=meas_var;    
    br_area=find(nbrr(n)==busdata(:,1));  % Area of branch's sending bus
    zdata(zdata_cnt,:)=[zdata_cnt measType noise+instr_imp+SnkPrel(n) ...
        nbrr(n) kbr(n) measVariance(measType) busdata(br_area,12) ...
        NumArea(br_area) pdf_travtime(br_area,1) ...
        pdf_travtime(br_area,2) t_break(br_area)];
    zdata_cnt=zdata_cnt + 1;
end

% Reactive power flow measurements
measType=5;
for n=[2 4 10 20]
    if rng_opt==1
        rng(0);
    end
    meas_var=abs(SnkQrel(n))*measVariance(measType); % Variance as value percentage
    instr_imp=sqrt(meas_var)*randn(1,1);             % instrument imperfection
    noise=noise_mean+sqrt(noise_var)*randn(1,1);     % noise
    MeasCov(zdata_cnt,zdata_cnt)=meas_var;
    br_area=find(nbrr(n)==busdata(:,1));  % Area of branch's sending bus
    zdata(zdata_cnt,:)=[zdata_cnt measType noise+instr_imp+SnkQrel(n) ...
        nbrr(n) kbr(n) measVariance(measType) busdata(br_area,12) ...
        NumArea(br_area) pdf_travtime(br_area,1) ...
        pdf_travtime(br_area,2) t_break(br_area)];
    zdata_cnt=zdata_cnt+1;
end

% Current flow measurements
measType=7;
for n=1:0
    if rng_opt==1
        rng(0);
    end
    meas_var=abs(InkMrel(n))*measVariance(measType); % Variance as value percentage
    instr_imp=sqrt(meas_var)*randn(1,1);             % instrument imperfection
    noise=noise_mean+sqrt(noise_var)*randn(1,1);     % noise
    MeasCov(zdata_cnt,zdata_cnt)=meas_var;
    br_area=find(nbrr(n)==busdata(:,1));  % Area of branch's sending bus
    zdata(zdata_cnt,:)=[zdata_cnt measType noise+instr_imp+InkMrel(n) ...
        nbrr(n) kbr(n) measVariance(measType) busdata(br_area,12) ...
        NumArea(br_area) pdf_travtime(br_area,1) ...
        pdf_travtime(br_area,2) t_break(br_area)];
    zdata_cnt=zdata_cnt+1;
end

% Voltage angle measurements
measType=6;
for n=1:nbus
    nodeType=busdata(n,2);
    if nodeType~=1 || opt6==0
        if rng_opt==1
            rng(0);
        end
        meas_var=abs(delta(n))*measVariance(measType); % Variance as value percentage
        instr_imp=sqrt(meas_var)*randn(1,1);           % instrument imperfection
        noise=noise_mean+sqrt(noise_var)*randn(1,1);   % noise
        MeasCov(zdata_cnt,zdata_cnt)=meas_var;
        zdata(zdata_cnt,:)=[zdata_cnt measType noise+instr_imp+delta(n) ...
            n 0 measVariance(6) Area(n) NumArea(n) pdf_travtime(n,1) ...
            pdf_travtime(n,2) t_break(n)];
        zdata_cnt=zdata_cnt + 1;
    end
end

% Voltage magnitude measurements
measType=1;
for n=1:nbus
    if rng_opt==1
        rng(0);
    end
    meas_var=abs(Vm(n))*measVariance(measType);  % Variance as value percentage
    instr_imp=sqrt(meas_var)*randn(1,1);         % instrument imperfection
    noise=noise_mean+sqrt(noise_var)*randn(1,1); % noise
    MeasCov(zdata_cnt,zdata_cnt)=meas_var;
    zdata(zdata_cnt,:)=[zdata_cnt measType noise+instr_imp+Vm(n) ...
        n 0 measVariance(measType) Area(n) NumArea(n) pdf_travtime(n,1) ...
        pdf_travtime(n,2) t_break(n)];
    zdata_cnt=zdata_cnt+1;
end




