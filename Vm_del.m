% Vm_del
% Selection of Vm (voltage magnitude) and del (voltage angles) from unique state vector (E)
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [Vm,del]=Vm_del(X,opt6)

global busdata

nbus=length(busdata(:,1)); % Get number of buses
ktek=0;
for ii=1:nbus
    if busdata(ii,2)==1 && opt6
        del(ii,1)=0;
    else
        ktek=ktek+1;  del(ii,1)=X(ktek,1);
    end
end
if opt6
    Vm=X(nbus:end);
else
    Vm=X(nbus+1:end);
end

