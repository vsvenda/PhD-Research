function system_initialization(in_file1)

global busdata linedata

switch in_file1
    case 'IEEE_14_bus_test_system'
        run(in_file1);
    case 'IEEE_14_bus_test_system_Abur'
        run(in_file1);
    case 'IEEE_300_bus_test_system'
        run(in_file1);
    case '2746WP'
        system = case2746wp;
        % busdata ********************
        % bus indx
        busdata(:,1) = system.bus(:,1);
        % bus type
        busdata(:,2) = 0; busdata(1,2) = 1;
        % bus voltage
        busdata(:,3) = system.bus(:,8); % magnitude
        busdata(:,4) = system.bus(:,9).*pi./180; % angle
        % bus load
        busdata(:,5) = system.bus(:,3)*100; % P(MW)
        busdata(:,6) = system.bus(:,4)*100; % Q(MVAr)
        % generators
        busdata(:,7) = 0; busdata(:,8) = 0;
        busdata(:,9) = 0; busdata(:,10) = 0;
        busdata(:,11) = 0;
        for i = 1:length(system.gen)
            busdata(system.gen(i,1),7) = system.gen(i,2)*100;   % P(MW)
            busdata(system.gen(i,1),8) = system.gen(i,3)*100;   % Q(MVAr)
            busdata(system.gen(i,1),9) = system.gen(i,5)*100;   % Qmin(MVAr)
            busdata(system.gen(i,1),10) = system.gen(i,4)*100;  % Qmax(MVAr)
            busdata(system.gen(i,1),11) = system.gen(i,13)*100; % +Qc/-Q1
        end
        % bus area and indx in area
        busdata(:,12) = 1; % fix if co-simulating with NS-2
        busdata(:,13) = 1;

        % linedata ********************
        % branch bus indx
        linedata(:,1) = system.branch(:,1); % leading
        linedata(:,2) = system.branch(:,2); % receiving
        % branch parameters
        linedata(:,3) = system.branch(:,3); % R (p.u.)
        linedata(:,4) = system.branch(:,4); % X (p.u.)
        linedata(:,5) = system.branch(:,5); % B (p.u.)
        % transformer ratio
        linedata(:,6) = system.branch(:,9);
end
end