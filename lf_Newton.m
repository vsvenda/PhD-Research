% lf_Newton_AS
% Power flow solution by Newton-Raphson method (recoded)
% 1. Original program does't work for paralel branches!
% 2. Time consuming
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [J,dP,X,ns,nss,tech,maxerror,iter,Pdt,Qdt,Pgt,Qgt,Qsht]...
    =lf_Newton(Vm0,delta0,Pfactor,Ybus,accuracy,maxiter,opt4)

global busdata basemva

ns=0; ng=0; Vm=0; delta=0; yload=0;
nbus=length(busdata(:,1));

for k=1:nbus
    n=busdata(k,1);
    kb(n)=busdata(k,2);
    if opt4==1
        Vm(n)=1;
        delta(n)=0;
    elseif opt4==2
        Vm(n)=Vm0(n);
        delta(n)=delta0(n);
    end
    Pd(n)=busdata(k,5); % active power load
    Qd(n)=busdata(k,6); % reactive power load
    Pg(n)=busdata(k,7); % active power generation
    Qg(n)=busdata(k,8); % reactive power generation
    Qmin(n)=busdata(k,9);
    Qmax(n)=busdata(k,10);
    Qsh(n)=busdata(k,11);
    if Vm(n)<=0
        Vm(n)=1.0;
        V(n)=1+1i*0;
    else
        if kb(n)~=1
            delta(n)=delta(n);  % Initial voltage angles in [pu]
        elseif kb(n)==1   % Added by A.Saric
            delta(n)=0;     % Added by A.Saric
        end
        V(n)=Vm(n)*(cos(delta(n))+1i*sin(delta(n)));
        P(n)=(Pg(n)-Pd(n))/basemva;
        Q(n)=(Qg(n)-Qd(n)+ Qsh(n))/basemva;
        S(n)=P(n)+1i*Q(n);
    end
end
for k=1:nbus
    if kb(k)==1
        ns=ns+1; % ns is number of slack buses
    end         
    if kb(k)==2
        ng=ng+1; % ng is number of PV buses
    end         
    ngs(k)=ng;
    nss(k)=ns;
end
Ym=abs(Ybus); t=angle(Ybus);
m=2*nbus-ng-2*ns;
maxerror=1; converge=1;

iter = 0;
% Start of iterations
while maxerror >= accuracy && iter <= maxiter % Test for max. power mismatch
    J=zeros(m,m);
    iter=iter+1;
    for n=1:nbus
        nn=n-nss(n); %nn are non-slack buses
        lm=nbus+n-ngs(n)-nss(n)-ns;

        % Power injection increments
        Pk=0; Qk=0;
        for m=1:nbus
            if n~=m
                Qk=Qk-Vm(n)*Vm(m)*Ym(n,m)*sin(t(n,m)-delta(n)+delta(m));
                Pk=Pk+Vm(n)*Vm(m)*Ym(n,m)*cos(t(n,m)-delta(n)+delta(m));
            else
                Pk=Pk+Vm(n)^2*Ym(n,n)*cos(t(n,n));
                Qk=Qk-Vm(n)^2*Ym(n,n)*sin(t(n,n));
            end
        end

        J11=0; J22=0; J33=0; J44=0;     %Jacobian submatrices
        for m=1:nbus                    %nbus is number of buses
            if n~=m && Ym(n,m)~=0
                J11=J11+Vm(n)*Vm(m)*Ym(n,m)*sin(t(n,m)-delta(n)+delta(m));
                J33=J33+Vm(n)*Vm(m)*Ym(n,m)*cos(t(n,m)-delta(n)+delta(m));
                if kb(n)~=1             % For non-slack buses!
                    J22=J22+Vm(m)*Ym(n,m)*cos(t(n,m)-delta(n)+delta(m));
                    J44=J44+Vm(m)*Ym(n,m)*sin(t(n,m)-delta(n)+delta(m));
                end
                if kb(n)~=1 && kb(m)~=1
                    lk=nbus+m-ngs(m)-nss(m)-ns;
                    ll=m-nss(m);
                    J(nn,ll)=-Vm(n)*Vm(m)*Ym(n,m)*sin(t(n,m)-delta(n)+delta(m));    % off diagonal elements of J1
                    if kb(m)==0
                        J(nn,lk)=Vm(n)*Ym(n,m)*cos(t(n,m)-delta(n)+delta(m));       % off diagonal elements of J2
                    end          
                    if kb(n)==0
                        J(lm,ll)=-Vm(n)*Vm(m)*Ym(n,m)*cos(t(n,m)-delta(n)+delta(m));% off diagonal elements of J3
                    end  
                    if kb(n)==0 && kb(m)==0
                        J(lm,lk)=-Vm(n)*Ym(n,m)*sin(t(n,m)-delta(n)+delta(m));      % off diagonal elements of J4
                    end         
                end
            end
        end
        if kb(n)==1 % Swing bus P
            P(n)=Pk;
            Q(n)=Qk;
        end
        if kb(n)==2  % PV bus
            Q(n)=Qk;
            if Qmax(n)~=0
                Qgc=Q(n)*basemva+Qd(n)-Qsh(n);
                if iter<=7                      % Between the 2nd & 6th iterations
                    if iter>2                   % the Mvar of generator buses are
                        if Qgc<Qmin(n)          % tested. If not within limits Vm(n)
                            Vm(n)=Vm(n)+0.01;   % is changed in steps of 0.01 pu to
                        elseif Qgc>Qmax(n)      % bring the generator Mvar within
                            Vm(n)=Vm(n)-0.01;   % the specified limits.
                        end
                    end
                end
            end
        end
        if kb(n)~=1
            J(nn,nn)=J11;   % diagonal elements of J11
            DC(nn)=P(n)-Pk;
            dP(nn)=Pfactor(n)*P(n);
        end
        if kb(n)==0
            J(nn,lm)=2*Vm(n)*Ym(n,n)*cos(t(n,n))+J22;   %diagonal elements of J2
            J(lm,nn)=J33;                               %diagonal elements of J3
            J(lm,lm)=-2*Vm(n)*Ym(n,n)*sin(t(n,n))-J44;  %diagonal of elements of J4
            DC(lm)=Q(n)-Qk;
            dP(lm)= Pfactor(n)*Q(n);
        end
    end                        % End of Jacobian calculation!
    DX=J\DC';
    for n=1:nbus
        nn=n-nss(n);
        lm=nbus+n-ngs(n)-nss(n)-ns;
        if kb(n)~=1
            delta(n)=delta(n)+DX(nn);
            X(nn)=delta(n);
        elseif kb(n)==1   % Added by A.Saric
            delta(n)=0;     % Added by A.Saric
        end
        if kb(n)==0
            Vm(n)=Vm(n)+DX(lm);
            X(lm)=Vm(n);
        end
    end
    maxerror=max(abs(DC));
    if iter==maxiter && maxerror>accuracy
        fprintf('\nWARNING: Iterative solution for PF did not converged after ')
        fprintf('%g', iter), fprintf(' iterations.\n\n')
        fprintf('Press Enter to terminate the iterations and print the results \n')
        converge=0;
        pause,
    end

end

if converge~=1
    tech= ('                      ITERATIVE SOLUTION DID NOT CONVERGE');
else
    tech=('                   Power Flow Solution by Newton-Raphson Method');
end
k=0;
for n=1:nbus
    if kb(n)==1
        k=k+1;
        S(n)=P(n)-1i*Q(n);
        Pg(n)=P(n)*basemva+Pd(n);
        Qg(n)=Q(n)*basemva+Qd(n)-Qsh(n);
        Pgg(k)=Pg(n);
        Qgg(k)=Qg(n);
    elseif kb(n)==2
        k=k+1;
        S(n)=P(n)+1i*Q(n);
        Qg(n)=Q(n)*basemva+Qd(n)-Qsh(n);
        Pgg(k)=Pg(n);
        Qgg(k)=Qg(n);
    end
    yload(n)=(Pd(n)-1i*Qd(n)+1i*Qsh(n))/(basemva*Vm(n)^2);
end
busdata(:,3)=Vm'; busdata(:,4)=delta'; busdata(:,7)=Pg; busdata(:,8)=Qg;
Pgt=sum(Pg);  Qgt=sum(Qg); Pdt=sum(Pd); Qdt=sum(Qd); Qsht=sum(Qsh);

