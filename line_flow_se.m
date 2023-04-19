% line_flow_se
% Calculation of line flows after State Estimation (SE)
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function line_flow_se(Ybus,opt1)

global busdata linedata basemva

Vm=busdata(:,3);
delta=busdata(:,4);
nbus=length(busdata(:,1));
nbr=length(linedata(:,1));
nl=linedata(:,1); nr=linedata(:,2);
V=Vm.*cos(delta)+1i*Vm.*sin(delta);
R=linedata(:,3);
X=linedata(:,4);
Bc=1i*linedata(:,5);
a=linedata(:,6);
Z=R+1i*X;
y=ones(nbr,1)./Z;        %branch admittance
I=Ybus*V;
S=V.*conj(I);

total_losses=0;
broj=1;
if opt1~=0
    fprintf('\n')
    fprintf('                 Line Flow and Losses - After State Estimation (SE) \n\n')
    fprintf('     --Line--  Power at bus & line flow    --Line loss--  Transformer\n')
    fprintf('     from  to    MW      Mvar     MVA       MW      Mvar      tap\n')
end

for n=1:nbus
    busprt=0;
    for L=1:nbr
        if busprt==0
            if opt1~=0
                fprintf('\n %6g     %9.3f%9.3f%9.3f \n', n,real(S(n))*basemva,imag(S(n))*basemva,abs(S(n)*basemva))
            end
            busprt=1;
        end
        if nl(L)==n
            k=nr(L);                               %In - Rated current
            In=(V(n)-a(L)*V(k))*y(L)/a(L)^2+Bc(L)/a(L)^2*V(n);  %y= ones(nbr,1)./Z; ----> Branch admittance
            Ik=(V(k)-V(n)/a(L))*y(L)+Bc(L)*V(k);                %L-th branch admittance
            Snk=V(n)*conj(In)*basemva;
            Skn=V(k)*conj(Ik)*basemva;
            branch_losses=Snk+Skn;
            total_losses=total_losses+branch_losses;
        elseif nr(L)==n
            k=nl(L);
            In=(V(n)-V(k)/a(L))*y(L)+Bc(L)*V(n);
            Ik=(V(k)-a(L)*V(n))*y(L)/a(L)^2+Bc(L)/a(L)^2*V(k);
            Snk=V(n)*conj(In)*basemva;
            Skn=V(k)*conj(Ik)*basemva;
            branch_losses=Snk+Skn;
            total_losses=total_losses+branch_losses;
        else, end
        if nl(L)==n || nr(L)==n
            if opt1~=0
                fprintf('%12g', k);
                fprintf('%9.3f', real(Snk)), fprintf('%9.3f', imag(Snk));
                fprintf('%9.3f', abs(Snk));
                fprintf('%9.3f', real(branch_losses));
            end
            if nl(L) ==n && a(L) ~= 1
                if opt1~=0
                    fprintf('%9.3f', imag(branch_losses)), fprintf('%9.3f\n', a(L));
                end
            else
                if opt1~=0
                    fprintf('%9.3f\n', imag(branch_losses));
                end
            end
        else, end
    end
end
total_losses = total_losses/2;
if opt1~=0
    fprintf('   \n'), fprintf('    Total losses                       ');
    fprintf('%9.3f', real(total_losses)), fprintf('%9.3f\n\n\n', imag(total_losses));
end


