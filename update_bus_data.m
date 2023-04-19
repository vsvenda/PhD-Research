% update_bus_data
% Update bus data with consumption/generation curves for current time
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [Pfactor]=update_bus_data(busdata_initial,loadCurve1,...
    loadCurve2,loadCurve3,loadCurve4,genCurveHydro,genCurveThermo,...
    genCurveSolar,genCurveWind,timeSequence1,clock1,clock2,opt3)

global busdata

nbus=length(busdata_initial(:,1));
Pfactor=zeros(nbus,1);

Ppcoeff  =[0 0 0 0];  Pgcoeff =[0 0 0];
Ppcoeff2 =[0 0 0 0];  Pgcoeff2=[0 0 0];
% Get active power load coefficients
% Present moment
Ppcoeff(1)=get_Pload(loadCurve1,timeSequence1,clock1(1),clock1(2),clock1(3),opt3);
Ppcoeff(2)=get_Pload(loadCurve2,timeSequence1,clock1(1),clock1(2),clock1(3),opt3);
Ppcoeff(3)=get_Pload(loadCurve3,timeSequence1,clock1(1),clock1(2),clock1(3),opt3);
Ppcoeff(4)=get_Pload(loadCurve4,timeSequence1,clock1(1),clock1(2),clock1(3),opt3);
% Next calculation time
Ppcoeff2(1)=get_Pload(loadCurve1,timeSequence1,clock2(1),clock2(2),clock2(3),opt3);
Ppcoeff2(2)=get_Pload(loadCurve2,timeSequence1,clock2(1),clock2(2),clock2(3),opt3);
Ppcoeff2(3)=get_Pload(loadCurve3,timeSequence1,clock2(1),clock2(2),clock2(3),opt3);
Ppcoeff2(4)=get_Pload(loadCurve4,timeSequence1,clock2(1),clock2(2),clock2(3),opt3);

% Get active power generation coefficients
% Present moment
Pgcoeff(1)=get_Pload(genCurveHydro,timeSequence1,clock1(1),clock1(2),clock1(3),opt3);
Pgcoeff(2)=get_Pload(genCurveThermo,timeSequence1,clock1(1),clock1(2),clock1(3),opt3);
Pgcoeff(3)=get_Pload(genCurveSolar,timeSequence1,clock1(1),clock1(2),clock1(3),opt3);
Pgcoeff(4)=get_Pload(genCurveWind,timeSequence1,clock1(1),clock1(2),clock1(3),opt3);
% Next calculation time
Pgcoeff2(1)=get_Pload(genCurveHydro,timeSequence1,clock2(1),clock2(2),clock2(3),opt3);
Pgcoeff2(2)=get_Pload(genCurveThermo,timeSequence1,clock2(1),clock2(2),clock2(3),opt3);
Pgcoeff2(3)=get_Pload(genCurveSolar,timeSequence1,clock2(1),clock2(2),clock2(3),opt3);
Pgcoeff2(4)=get_Pload(genCurveWind,timeSequence1,clock2(1),clock2(2),clock2(3),opt3);

% Iteration through all system buses
for k=1:nbus
    nodeType=busdata_initial(k,2);
    if nodeType==0 || nodeType==2
        % Load (PQ) buses, using Load Curves
        switch (rem(k,4))
            case 0
                Pp_coeff=Ppcoeff(1);
                if Ppcoeff(1)==0
                    Pfactor(k)=0;
                else
                    Pfactor(k)=Ppcoeff2(1)/Ppcoeff(1)-1;
                end
            case 1
                Pp_coeff=Ppcoeff(2);
                if Ppcoeff(2)==0
                    Pfactor(k)=0;
                else
                    Pfactor(k)=Ppcoeff2(2)/Ppcoeff(2)-1;
                end
            case 2
                Pp_coeff=Ppcoeff(3);
                if Ppcoeff(3)==0
                    Pfactor(k)=0;
                else           
                    Pfactor(k)=Ppcoeff2(3)/Ppcoeff(3)-1;
                end
            case 3
                Pp_coeff=Ppcoeff(4);
                if Ppcoeff(4)==0
                    Pfactor(k)=0;
                else
                    Pfactor(k)=Ppcoeff2(4)/Ppcoeff(4)-1;
                end
        end
        busdata(k,5)=busdata_initial(k,5)*Pp_coeff;
        busdata(k,6)=busdata_initial(k,6)*Pp_coeff;
    end
    if nodeType==2
        % Generating (PV) buses, using Generator Curves
        switch (rem(k,4))
            case 0
                Pg_coeff=Pgcoeff(1);
                if Pgcoeff(1)==0
                    Pfactor(k)=0;
                else 
                    Pfactor(k)=Pgcoeff2(1)/Pgcoeff(1)-1;
                end
            case 1
                Pg_coeff=Pgcoeff(2);
                if Pgcoeff(2)==0
                    Pfactor(k)=0;
                else            
                    Pfactor(k)=Pgcoeff2(2)/Pgcoeff(2)-1;
                end
            case 2
                Pg_coeff=Pgcoeff(3);
                if Pgcoeff(3)==0
                    Pfactor(k)=0;
                else
                    Pfactor(k)=Pgcoeff2(3)/Pgcoeff(3)-1;
                end
            case 3
                Pg_coeff=Pgcoeff(4);
                if Pgcoeff(4)==0
                    Pfactor(k)=0;
                else
                    Pfactor(k)=Pgcoeff2(4)/Pgcoeff(4)-1;
                end
        end
        busdata(k,7)=busdata_initial(k,7)*Pg_coeff;
        busdata(k,8)=busdata_initial(k,8)*Pg_coeff; 
    end
end