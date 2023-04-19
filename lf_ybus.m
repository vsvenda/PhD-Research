% lf_ybus
% This program obtains the Bus Admittance Matrix for power flow solution
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [Ybus] = lf_ybus()

global busdata linedata

nl=linedata(:,1);
nr=linedata(:,2);
R=linedata(:,3);
X=linedata(:,4);
Bc=1i*linedata(:,5);
a=linedata(:,6);
nbr=length(linedata(:,1));
nbus=length(busdata(:,1));

Z=R+1i*X; y=ones(nbr,1)./Z; % branch admittance

Ybus=zeros(nbus,nbus);      % initialize Ybus to zero
% formation of the off diagonal elements
for k=1:nbr
    if a(k)<=0
        a(k)=1;
    end
    Ybus(nl(k),nr(k))=Ybus(nl(k),nr(k))-y(k)/a(k);
    Ybus(nr(k),nl(k))=Ybus(nl(k),nr(k));
end
% formation of the diagonal elements
for n=1:nbus
    for k=1:nbr
        if nl(k)==n
            Ybus(n,n)=Ybus(n,n)+y(k)/(a(k)^2)+Bc(k);
        elseif nr(k)==n
            Ybus(n,n)=Ybus(n,n)+y(k)+Bc(k);
        end
    end
end
