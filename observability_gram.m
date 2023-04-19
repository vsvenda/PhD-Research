% observability_gram
% Forming the non-redundant set of measurements with which
% network observability is achieved
% Based on A. Garcia, "Power System Observability Analysis Based on
%                      Gram Matrix and Minimum Norm Solution," 2008; and
%          A. Garcia, "On the Use of Gram Matrix in
%                      Observability Analysis," 2008
% Author: Vanja Svenda and Alex Stankovic

function [nr_mset,delta_time,delta_perc] = observability_gram(zdata,Ybus,opt6)

global busdata linedata

% Initialization **********************************************************
nbus=length(busdata(:,1)); % Get number of buses
nbr=length(linedata(:,1)); % Get number of branches

for i=1:nbr
    m=linedata(i,1);
    n=linedata(i,2);
    bpq(m,n)=linedata(i,5);
    bpq(n,m)=linedata(i,5);
end
type=zdata(:,2);      % Types of measurements: 1 (Vi), 2 (Pi), 3 (Qi), 4 (Pij), 5 (Qij), 6 (Thetaij), 7 (Iij)
fbus=zdata(:,4);      % From bus
tbus=zdata(:,5);      % To bus
R=linedata(:,3);
X=linedata(:,4);
Bc=1i*linedata(:,5);
a=linedata(:,6);
Ri=diag(zdata(:,6));  % Measurement Error
Vm=busdata(:,3);      % NZ - soft start
del=busdata(:,4);
Z=R+1i*X;
yline=ones(nbr,1)./Z; %branch admittance

ppi=find(type==2);  % Index of real power injection measurements
pf =find(type==4);  % Index of real powerflow measurements
ti =find(type==6);  % Index of voltage angle measurements

npi=length(ppi); % Number of Real Power Injection measurements
npf=length(pf);  % Number of Real Power Flow measurements
nti=length(ti);  % Number of Voltage angle measurements
G=real(Ybus);
B=imag(Ybus);
nl=linedata(:,1);
V1=Vm.*(cos(del)+1i*sin(del));

% Matrix H ****************************************************************
% H_dc1 - Derivative of Real Power Injections with Angles..
H_dc1=zeros(npi,nbus-opt6);
for i=1:npi
    m=fbus(ppi(i));
    for k=1:(nbus-opt6)
        if k+opt6==m
            for n=1:nbus
                H_dc1(i,k)=H_dc1(i,k)+Vm(m)*Vm(n)*(-G(m,n)*sin(del(m)-del(n))+B(m,n)*cos(del(m)-del(n)));
            end
            H_dc1(i,k)=H_dc1(i,k)-Vm(m)^2*B(m,m);
        else
            H_dc1(i,k)=Vm(m)*Vm(k+opt6)*( G(m,k+opt6)*sin(del(m)-del(k+opt6))-B(m,k+opt6)*cos(del(m)-del(k+opt6)));
        end
    end
end
[mm, ~]=size(H_dc1); % matrix reduction in accordance with outage instruments
for kk=mm:-1:1
    if zdata(ppi(kk),14)==1
        H_dc1=delete_row(H_dc1,kk);
        ppi=delete_row(ppi,kk);
    end
end

% H_dc2 - Derivative of Real Power Flows with Angles..
H_dc2=zeros(npf,nbus-opt6);
for i=1:npf
    m=fbus(pf(i)); n=tbus(pf(i));
    lIndex=line_index(linedata,m,n);
    for k=1:(nbus-opt6)
        if k+opt6==m
            H_dc2(i,k)= Vm(m)*Vm(n)*(real(yline(lIndex))*sin(del(m)-del(n))-imag(yline(lIndex))*cos(del(m)-del(n)));
        elseif k+opt6==n
            H_dc2(i,k)=-Vm(m)*Vm(n)*(real(yline(lIndex))*sin(del(m)-del(n))-imag(yline(lIndex))*cos(del(m)-del(n)));
        end
    end
end
[mm, ~]=size(H_dc2); % matrix reduction in accordance with outage instruments
for kk=mm:-1:1
    if zdata(pf(kk),14)==1
        [H_dc2]=delete_row(H_dc2,kk);
        pf=delete_row(pf,kk);
    end
end

% H_dc3 - Derivative of angles with respect to angles
H_dc3=zeros(nti,nbus-opt6);
for m=1:nti
    for n=1:nbus-opt6
        if n+opt6==fbus(ti(m))
            H_dc3(m,n)=1;
        end
    end
end
[mm, ~]=size(H_dc3); % matrix reduction in accordance with outage instruments
for kk=mm:-1:1
    if zdata(ti(kk),14)==1
        [H_dc3]=delete_row(H_dc3,kk);
        ti=delete_row(ti,kk);
    end
end

% H_dc=[H_dc1; H_dc2; H_dc3]; mset=[ppi; pf; ti]; % Pinj Pflow Theta
% H_dc=[H_dc2; H_dc1; H_dc3]; mset=[pf; ppi; ti]; % Pflow Pinj Theta
H_dc=[H_dc3; H_dc1; H_dc2]; mset=[ti; ppi; pf]; % Theta Pinj Pflow

% Initial meas. set *******************************************************
H_nr=H_dc(1,:);
nr_mset=mset(1);
meas_cnt=1;
for i=2:size(mset)
    H_nrTest=[H_nr; H_dc(i,:)];
    A=H_nrTest*H_nrTest';
    [Alow,Aup]=lu(A);
    Test=1;
    for k=1:size(Aup,1)
        if abs(Aup(k,k))<1e-3
            Test=0;
            break;
        end
    end
    if Test==1
        H_nr=[H_nr; H_dc(i,:)];
        nr_mset=[nr_mset; mset(i)];
        meas_cnt=meas_cnt+1;
    end
    if meas_cnt>=(nbus-opt6)
        break;
    end
end

A_initial=H_nr*H_nr';
obs_prob=0;
loop_check=1;
for i_perc=0.99:-0.01:0.01
    A=A_initial;
    while (loop_check)
        for i=1:size(H_dc,1)
            if (ismember(mset(i),nr_mset)==0)
                r_vect=H_dc(i,:)*H_nr'/A;
                r_vect(abs(r_vect)<1e-6)=0;
                r_change=find(r_vect);
                travtime=norminv(i_perc,zdata(mset(i),9),zdata(mset(i),10));
                travtime=[travtime zeros(1,length(r_change))];
                for k=1:length(r_change)
                    travtime(k+1)=norminv(i_perc,zdata(nr_mset(r_change(k)),9),...
                        zdata(nr_mset(r_change(k)),10));
                end
                [~,max_ind]=max(travtime);
                if max_ind~=1
                    nr_mset(r_change(max_ind-1))=mset(i);
                    H_nr(r_change(max_ind-1),:)=H_dc(i,:);
                    A=H_nr*H_nr';
                    loop_check=0;
                end
            end
            if i>=size(H_dc,1) && loop_check==0
                loop_check=1;
            elseif i>=size(H_dc,1) && loop_check==1
                loop_check=0;
            end
        end
    end
    travtime=zeros(1,length(nr_mset));
    for i=1:length(nr_mset)
        travtime(i)=norminv(i_perc,zdata(nr_mset(i),9),zdata(nr_mset(i),10));
    end
    obs_p=i_perc*3600/max(travtime);
    if obs_p>obs_prob
        obs_prob=obs_p;
        delta_time=max(travtime);
        delta_time=round(delta_time*10)/10;
        delta_perc=i_perc;
    end
end

% *************************************************************************
% Matrix H observable islands *********************************************
% ppi=[2 5 6];
% npi=length(ppi);
% % H_obs1 - Derivative of Real Power Injections with Angles..
% H_obs1=zeros(npi,nbus);
% for i=1:npi
%     m=fbus(ppi(i));
%     for k=1:nbus
%         if k==m
%             for n=1:nbus
%                 H_obs1(i,k)=H_obs1(i,k)+Vm(m)*Vm(n)*(-G(m,n)*sin(del(m)-del(n))+B(m,n)*cos(del(m)-del(n)));
%             end
%             H_obs1(i,k)=H_obs1(i,k)-Vm(m)^2*B(m,m);
%         else
%             H_obs1(i,k)=Vm(m)*Vm(k)*( G(m,k)*sin(del(m)-del(k))-B(m,k)*cos(del(m)-del(k)));
%         end
%     end
% end
%
% % H_obs2 - Derivative of Real Power Flows with Angles..
% H_obs2=zeros(npf,nbus);
% for i=1:npf
%     m=fbus(pf(i)); n=tbus(pf(i));
%     lIndex=line_index(linedata,m,n);
%     for k=1:nbus
%         if k==m
%             H_obs2(i,k)= Vm(m)*Vm(n)*(real(yline(lIndex))*sin(del(m)-del(n))-imag(yline(lIndex))*cos(del(m)-del(n)));
%         elseif k+1==n
%             H_obs2(i,k)=-Vm(m)*Vm(n)*(real(yline(lIndex))*sin(del(m)-del(n))-imag(yline(lIndex))*cos(del(m)-del(n)));
%         end
%     end
% end
%
% % H_obs3 - Derivative of angles with respect to angles
% H_obs3=zeros(nti,nbus);
% for m=1:nti,
%     for n=1:nbus
%         if n==fbus(ti(m)),  H_obs3(m,n)=1; end
%     end
% end
% H_obs3=[1 0 0 0 0 0 0 0 0 0 0 0 0 0];
%
% H_obs=[H_obs3; H_obs2; H_obs1];
% H_nr_obs=H_obs;
% A_obs=H_nr_obs*H_nr_obs';
% z=[1 0 0 0 0 0 0 0 0 0 0];
% theta_obs=H_nr_obs'*inv(A_obs)*z';





