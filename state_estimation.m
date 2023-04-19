% state_estimation
% State Estimation
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [H,Vm,del,E,obs_check,H_reduced,Gm_reduced,...
    Ri_reduced,zdata_reduced,h_reduced,kept_measurements,convCnt,r,deltaE]=...
    state_estimation(linedata_SE,zdata,Ybus,accuracy,maxiter,sens_matr,...
    convCnt,opt6,E_start,unobs_ind)

global busdata linedata t_step_se

% linedata_SE=linedata % if we want SE to "see" changes in network (i.e. topology change)

nobserv=1; % 1 - rank of Jacobian matrix; 2 - QR method

obs_check=1;
nbus=length(busdata(:,1)); % Get number of buses
nbr=length(linedata_SE(:,1)); % Get number of branches

for i=1:nbr
    m=linedata_SE(i,1);
    n=linedata_SE(i,2);
    bpq(m,n)=linedata_SE(i,5); % 1/2 B (susceptance)
    bpq(n,m)=linedata_SE(i,5);
end
type=zdata(:,2);      % Types of measurements: 1 (Vi), 2 (Pi), 3 (Qi), 4 (Pij), 5 (Qij), 6 (Thetaij), 7 (Iij)
fbus=zdata(:,4);      % From bus
tbus=zdata(:,5);      % To bus
R=linedata_SE(:,3);
X=linedata_SE(:,4);
Bc=1i*linedata_SE(:,5);
a=linedata_SE(:,6);
Ri=diag(zdata(:,6));  % Measurement Error
Vm=busdata(:,3);      % NZ - soft start
del=busdata(:,4);
Z=R+1i*X;
yline=ones(nbr,1)./Z; % Branch admittance

if sens_matr==0 % full SE or regenerating sensitivity matrices?
    E=E_start;  % State Vector; starting with previous values
else
    E=zeros(nbus-opt6,1);
    ktek=0;
    for ii=1:nbus
        if busdata(ii,2)~=1 || opt6==0
            ktek=ktek+1;  E(ktek,1)=busdata(ii,4);
        end
    end
    E=[E; Vm];  % Specific case when we only need sensitivity matrices
end

vi =find(type==1);  % Index of voltage magnitude measurements
ppi=find(type==2);  % Index of real power injection measurements
qi =find(type==3);  % Index of reactive power injection measurements
pf =find(type==4);  % Index of real powerflow measurements
qf =find(type==5);  % Index of reactive powerflow measurements
ti =find(type==6);  % Index of voltage angle measurements
im =find(type==7);  % Index of current flow magnitude measurements

nvi=length(vi);     % Number of Voltage magnitude measurements
npi=length(ppi);    % Number of Real Power Injection measurements
nqi=length(qi);     % Number of Reactive Power Injection measurements
npf=length(pf);     % Number of Real Power Flow measurements
nqf=length(qf);     % Number of Reactive Power Flow measurements
nti=length(ti);     % Number of Voltage angle measurements
nim=length(im);     % Number of Current flow magnitude measurements
G=real(Ybus);
B=imag(Ybus);
nl=linedata_SE(:,1);
nr=linedata_SE(:,2);

PFlineIndex=zeros(1,npf); % index of lines with power flow measurements (Julia)
ImlineIndex=zeros(1,nim); % index of lines with current mag. measurements (Julia)

iter=1; % Initial iteration
tol=5;  % Initial achieved convergance tolerance

while tol>accuracy && iter <= maxiter % Convergence (max. iter) test
    V1=Vm.*(cos(del)+1i*sin(del));
    % Measurement function (h) ************************************************
    h1=zeros(npi,1);      % Active power injection
    h2=zeros(nqi,1);      % Reactive power injection
    h3=zeros(npf,1);      % Active power flow
    h4=zeros(nqf,1);      % Reactive power flow
    h5=zeros(nim,1);      % Current magnitude
    h6=del(fbus(ti),1);   % Voltage angle
    h7=Vm(fbus(vi),1);    % Voltage magnitude

    I=Ybus*V1;
    if npi~=0 % Power injection
        for i=1:npi
            m=fbus(ppi(i));
            PQ(i,1)=V1(m)*conj(I(m));
        end
        h1=real(PQ);
        h2=imag(PQ);
    end

    if npf~=0 % Power flow
        for i=1:npf
            m=fbus(pf(i)); n=tbus(pf(i));
            lIndex=line_index(linedata_SE,m,n);
            PFlineIndex(i)=lIndex;
            if nl(lIndex)==m
                PQF(i,1)=V1(m)*conj((V1(m)-a(lIndex(1))*V1(n))*yline(lIndex(1))/a(lIndex(1))^2+Bc(lIndex(1))/a(lIndex(1))^2*V1(m));
            else
                PQF(i,1)=V1(m)*conj((V1(m)-V1(n)/a(lIndex(1)))*yline(lIndex(1))+Bc(lIndex(1))*V1(m));
            end
        end
        h3=real(PQF);
        h4=imag(PQF);
    end
    if nim~=0 % Current magnitude
        for i=1:nim
            m=fbus(im(i)); n=tbus(im(i));
            lIndex=line_index(linedata_SE,m,n);
            ImlineIndex(i)=lIndex;
            if nl(lIndex)==m
                Im(i,1)=(V1(m)-a(lIndex(1))*V1(n))*yline(lIndex(1))/a(lIndex(1))^2;
            else
                Im(i,1)=(V1(m)-V1(n)/a(lIndex(1)))*yline(lIndex(1));
            end
        end
        h5=abs(Im);
    end

    h=[h1; h2; h3; h4; h5; h6; h7]; % Measurement function (h)

    % Save necessary information for Julia (MBAM) input *******************
    if iter==1 && sens_matr==0
        % Ybus - admittance matrix
        % yline - line admittances
        % a - transformer ratio
        % Bc - shunt admittances
        % nl - leading buses as defined in linedata
        % nr - receiving buses as defined in linedata
        % nbus - number of buses in the system
        % nbr - number of branches in the system
        % opt6 - reference bus exists (1) or not (0)
        save('Julia_networkInfo.mat','Ybus','yline','a','Bc','nl','nr','nbus','nbr','opt6')
        % PFlineIndex - index of lines with power flow measurements
        % ImlineIndex - index of lines with current magnitude measurements
        % fbus/tbus - sending and receiving buses of measurements
        % npi/npf - number of power injection and flow measurements
        % nim - number of current magnitude measurements
        % nvi - number of voltage magnitude measurements
        % nti - number of voltage angle measurements
        % meas_type - measurement type
        % meas_data - measurement values
        % meas_var - measurement variances
        % m_outage - outage measurement instruments
        % E_start - voltage values from previous time instance
        meas_type=zdata(:,2);
        meas_data=zdata(:,3);
        meas_var=zdata(:,6);
        m_outage=zdata(:,14);
        save('Julia_measInfo.mat','PFlineIndex','ImlineIndex','fbus',...
            'tbus','npi','npf','nim','nvi','nti','meas_type','meas_data',...
            'meas_var','m_outage', 'E_start');
    end

    % Remove rows for dropped measurements
    zdata_reduced=zdata;
    h_reduced=h;
    kept_measurements=[];
    [mm, ~]=size(zdata_reduced);
    if iter==1, fprintf(' Number of measurements (original):     %5g \n', mm); end
    for kk=mm:-1:1
        if zdata_reduced(kk,12)>=t_step_se || zdata_reduced(kk,12)==0 ||...
                zdata_reduced(kk,12)==-1 || zdata_reduced(kk,14)==1
            [zdata_reduced]=delete_row(zdata_reduced,kk);
            [h_reduced]=delete_row(h_reduced,kk);
        else
            kept_measurements=[kk kept_measurements];
        end
    end
    Ri_reduced=diag(zdata_reduced(:,6)); % Measurement variance
    [mm, ~]=size(zdata_reduced);
    if iter==1
        fprintf(' Number of measurements after dropping: %5g \n\n', mm);
    end

    r=zdata(:,3)-h; % Residual vector
    r_reduced=zdata_reduced(:,3)-h_reduced;

    % Jacobian matrix (H) *****************************************************

    % H11 - Derivative of Real Power Injections with Angles..
    H11=zeros(npi,nbus-opt6);
    % H21 - Derivative of Reactive Power Injections with Angles..
    H21=zeros(nqi,nbus-opt6);
    for i=1:npi
        m=fbus(ppi(i));
        for k=1:(nbus-opt6)
            if k+opt6==m
                for n=1:nbus
                    H11(i,k)=H11(i,k)+Vm(m)*Vm(n)*(-G(m,n)*sin(del(m)-del(n))+B(m,n)*cos(del(m)-del(n)));
                    H21(i,k)=H21(i,k)+Vm(m)*Vm(n)*( G(m,n)*cos(del(m)-del(n))+B(m,n)*sin(del(m)-del(n)));
                end
                H11(i,k)=H11(i,k)-Vm(m)^2*B(m,m);
                H21(i,k)=H21(i,k)-Vm(m)^2*G(m,m);
            else
                H11(i,k)=Vm(m)*Vm(k+opt6)*( G(m,k+opt6)*sin(del(m)-del(k+opt6))-B(m,k+opt6)*cos(del(m)-del(k+opt6)));
                H21(i,k)=Vm(m)*Vm(k+opt6)*(-G(m,k+opt6)*cos(del(m)-del(k+opt6))-B(m,k+opt6)*sin(del(m)-del(k+opt6)));
            end
        end
    end

    % H12 - Derivative of Real Power Injections with V..
    H12=zeros(npi,nbus);
    % H22 - Derivative of Reactive Power Injections with V..
    H22=zeros(nqi,nbus);
    for i=1:npi
        m=fbus(ppi(i));
        for k=1:nbus
            if k==m
                for n=1:nbus
                    H12(i,k)=H12(i,k)+Vm(n)*(G(m,n)*cos(del(m)-del(n))+B(m,n)*sin(del(m)-del(n)));
                    H22(i,k)=H22(i,k)+Vm(n)*(G(m,n)*sin(del(m)-del(n))-B(m,n)*cos(del(m)-del(n)));
                end
                H12(i,k)=H12(i,k)+Vm(m)*G(m,m);
                H22(i,k)=H22(i,k)-Vm(m)*B(m,m);
            else
                H12(i,k)=Vm(m)*(G(m,k)*cos(del(m)-del(k))+B(m,k)*sin(del(m)-del(k)));
                H22(i,k)=Vm(m)*(G(m,k)*sin(del(m)-del(k))-B(m,k)*cos(del(m)-del(k)));
            end
        end
    end

    % H31 - Derivative of Real Power Flows with Angles..
    H31=zeros(npf,nbus-opt6);
    % H41 - Derivative of Reactive Power Flows with Angles..
    H41=zeros(nqf,nbus-opt6);
    for i=1:npf
        m=fbus(pf(i)); n=tbus(pf(i));
        lIndex=line_index(linedata_SE,m,n);
        for k=1:(nbus-opt6)
            if k+opt6==m
                H31(i,k)= Vm(m)*Vm(n)*(real(yline(lIndex))*sin(del(m)-del(n))-imag(yline(lIndex))*cos(del(m)-del(n)));
                H41(i,k)=-Vm(m)*Vm(n)*(real(yline(lIndex))*cos(del(m)-del(n))+imag(yline(lIndex))*sin(del(m)-del(n)));
            elseif k+opt6==n
                H31(i,k)=-Vm(m)*Vm(n)*(real(yline(lIndex))*sin(del(m)-del(n))-imag(yline(lIndex))*cos(del(m)-del(n)));
                H41(i,k)= Vm(m)*Vm(n)*(real(yline(lIndex))*cos(del(m)-del(n))+imag(yline(lIndex))*sin(del(m)-del(n)));
            end
        end
    end

    % H32 - Derivative of Real Power Flows with V..
    H32=zeros(npf,nbus);
    % H42 - Derivative of Reactive Power Flows with V..
    H42=zeros(nqf,nbus);
    for i=1:npf
        m=fbus(pf(i)); n=tbus(pf(i));
        lIndex=line_index(linedata_SE,m,n);
        for k=1:nbus
            if k==m
                H32(i,k)=-Vm(n)*(real(yline(lIndex))*cos(del(m)-del(n))+imag(yline(lIndex))*sin(del(m)-del(n)))+2*real(yline(lIndex))*Vm(m);
                H42(i,k)=-Vm(n)*(real(yline(lIndex))*sin(del(m)-del(n))-imag(yline(lIndex))*cos(del(m)-del(n)))-2*Vm(m)*(imag(yline(lIndex))+bpq(m,n));
            elseif k==n
                H32(i,k)=-Vm(m)*(real(yline(lIndex))*cos(del(m)-del(n))+imag(yline(lIndex))*sin(del(m)-del(n)));
                H42(i,k)=-Vm(m)*(real(yline(lIndex))*sin(del(m)-del(n))-imag(yline(lIndex))*cos(del(m)-del(n)));
            end
        end
    end

    % H51 - Derivative of Current flow magnitude with angles..
    H51=zeros(nim,nbus-opt6);
    for i=1:nim
        m=fbus(im(i)); n=tbus(im(i));
        lIndex=line_index(linedata_SE,m,n);
        for k=1:(nbus-opt6)
            if k+opt6==m
                H51(i,k)=(real(yline(lIndex))^2+imag(yline(lIndex))^2)/(a(lIndex(1))^3*abs((V1(m)-a(lIndex(1))*V1(n))*yline(lIndex(1))/a(lIndex(1))^2))*Vm(m)*Vm(n)*sin(del(m)-del(n));
            elseif k+opt6==n
                H51(i,k)=-(real(yline(lIndex))^2+imag(yline(lIndex))^2)/(a(lIndex(1))^3*abs((V1(m)-a(lIndex(1))*V1(n))*yline(lIndex(1))/a(lIndex(1))^2))*Vm(m)*Vm(n)*sin(del(m)-del(n));
            end
        end
    end
    % H52 - Derivative of Current flow magnitude with V..
    H52=zeros(nim,nbus);
    for i=1:nim
        m=fbus(im(i)); n=tbus(im(i));
        lIndex=line_index(linedata_SE,m,n);
        for k=1:nbus
            if k==m
                H52(i,k)=(real(yline(lIndex))^2+imag(yline(lIndex))^2)/(a(lIndex(1))^4*abs((V1(m)-a(lIndex(1))*V1(n))*yline(lIndex(1))/a(lIndex(1))^2))*(Vm(m)-a(lIndex(1))*Vm(n)*cos(del(m)-del(n)));
            elseif k==n
                H52(i,k)=(real(yline(lIndex))^2+imag(yline(lIndex))^2)/(a(lIndex(1))^3*abs((V1(m)-a(lIndex(1))*V1(n))*yline(lIndex(1))/a(lIndex(1))^2))*(a(lIndex(1))*Vm(n)-Vm(m)*cos(del(m)-del(n)));
            end
        end
    end

    % H61 - Derivative of angles with respect to angles..
    H61=zeros(nti,nbus-opt6);
    for m=1:nti
        for n=1:nbus-opt6
            if n+opt6==fbus(ti(m))
                H61(m,n)=1;
            end
        end
    end
    % H62 - Derivative of angles with respect to V.. All Zeros
    H62=zeros(nti,nbus);

    % H71 - Derivative of V with respect to angles.. All zeros
    H71=zeros(nvi,nbus-opt6);
    % H72 - Derivative of V with respect to V..
    H72=zeros(nvi,nbus);
    for m=1:nvi
        for n=1:nbus
            if n==fbus(vi(m))
                H72(m,n)=1;
            end
        end
    end

    % Measurement Jacobian (H)
    H=[H11 H12; H21 H22; H31 H32; H41 H42; H51 H52; H61 H62; H71 H72];

    if sens_matr==0 % Executing SSE (not recalculating sensitivity matrices)
        % Remove columns in matrix H for unobservable states
        H_reduced=H;
        num_est=2*nbus-opt6;
        [~, mm]=size(H_reduced);
        for kk=mm:-1:1
            if ismember(kk,unobs_ind)
                [H_reduced]=delete_column(H_reduced,kk);
                num_est=num_est-1;
            end
        end
        if iter==1, fprintf(' Number of states (total):   %5g \n', 2*nbus-opt6); end
        if iter==1, fprintf(' Number of estimated states: %5g \n\n', num_est); end
        % Remove rows in matrix H for dropped measurements
        [mm, ~]=size(H_reduced);
        for kk=mm:-1:1
            if zdata(kk,12)>=t_step_se || zdata(kk,12)==0 || zdata(kk,12)==-1 || zdata(kk,14)==1
                [H_reduced]=delete_row(H_reduced,kk);
            end
        end

        % Network observability check (case 1 - Jacobian matrix rank, case 2 - qr decomp. )
        if nobserv==1
            if rank(H_reduced)<(2*nbus-opt6-length(unobs_ind))
                fprintf('Network not observable !')
                obs_check=0;
                Gm_reduced=0; Ri_reduced=0;
                break;
            end
        elseif nobserv==2
            qr_check=qr_obs(H_reduced);
            if qr_check
                fprintf('Network not observable !')
                obs_check=0;
                Gm_reduced=0; Ri_reduced=0;
                break;
            end
        end
    end

    % State Vector
    if sens_matr==0
        Gm_reduced=H_reduced'*inv(Ri_reduced)*H_reduced; % Gain Matrix (Gm)
        dE=Gm_reduced\(H_reduced'*inv(Ri_reduced)*r_reduced);
        for k=1:length(unobs_ind) % Supplement vector dE with zeros for unobservable states
            dE=[dE(1:unobs_ind(k)-1); 0; dE(unobs_ind(k):end)];
        end
        if cond(dE)>1e+8 || cond(H_reduced)>1e+6 || cond(Ri_reduced)>1e+6
            fprintf('High condition number !')
            obs_check=0;
            Gm_reduced=0; Ri_reduced=0;
            break;
        end
    else
        Gm=H'*inv(Ri)*H; % Gain Matrix (Gm)
        dE=Gm\(H'*inv(Ri)*r);
    end

    E=E+dE;
    [Vm,del]=Vm_del(E,opt6);  % Change inside with accordance to REFERENCE BUS

    deltaE(iter)=max(dE);
    iter=iter+1;
    tol=max(abs(dE));

    if iter>=maxiter && tol>accuracy && maxiter>2 % SE went through max. iter
        ktek=0;
        for ii=1:nbus
            if busdata(ii,2)==1
                del1(ii,1)=0;
            else 
                ktek=ktek+1;
                del1(ii,1)=dE(ktek,1);
            end
        end
        Vm1=dE(nbus:end);
        [max1,i1]=max(abs(del1));
        [max2,i2]=max(abs(Vm1));

        fprintf('\nWARNING: Did not converged State Estimation (SE) after ')
        fprintf('%g', iter), fprintf(' iterations to tol=%8.6f.\n',accuracy)
        if max1>max2
            fprintf('Achieved tolerance=%8.6f for voltage angle in bus %d (%8.6f) \n\n',tol,i1,max1)
        else
            fprintf('Achieved tolerance=%8.6f for voltage magnitude in bus %d (%8.6f) \n\n',tol,i2,max2)
        end
        fprintf('Press Enter to continue with State Estimation in next time instant \n')
        convCnt=convCnt+1;
        obs_check=0;
        break;
    end
end


