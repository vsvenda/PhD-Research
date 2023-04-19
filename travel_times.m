% travel_times
% Deriving the Gaussian probability density functions (PDFs)
% for measurement travel times (deriving sample means and variances)
% Author: Vanja Svenda and Alex Stankovic

function [pdf_travtime] = travel_times(opt0)

if opt0==1 % IEEE 14 Bus System
    pdf_travtime=zeros(14,2);
    M_PMU_read=dlmread('Results_14_Bus_all_PMU.win.txt');
    M_PMU=zeros(size(M_PMU_read,1)-1,size(M_PMU_read,2));
    for i=1:size(M_PMU_read,2)
        k=2;
        while (k<=size(M_PMU_read,1))
            cnt=1;
            while (M_PMU_read(k,i)==0 && k<=size(M_PMU_read,1)) % check for dropped measurements
                M_PMU(k,i)=NaN;
                k=k+1;
                cnt=cnt+1;
                if (k>size(M_PMU_read,1))
                    break;
                end
            end
            if (k<=size(M_PMU_read,1))
                M_PMU(k-cnt,i)=M_PMU_read(k,i)+(cnt-1)*0.02+(0.02-M_PMU_read(k-cnt,i));
                k=k+1;
            end
        end
    end

    M_RTU_read=dlmread('Results_14_Bus_all_RTU.win.txt');
    M_RTU=zeros(size(M_RTU_read,1)-1,size(M_RTU_read,2));
    for i=1:size(M_RTU_read,2)
        k=2;
        while (k<=size(M_RTU_read,1))
            cnt=1;
            while (M_RTU_read(k,i)==0 && k<=size(M_RTU_read,1)) % check for dropped measurements
                M_RTU(k,i)=NaN;
                k=k+1;
                cnt=cnt+1;
                if (k>size(M_RTU_read,1))
                    break;
                end
            end
            if (k<=size(M_RTU_read,1))
                M_RTU(k-cnt,i)=M_RTU_read(k,i)+(cnt-1)*2+(2-M_RTU_read(k-cnt,i));
                k=k+1;
            end
        end
    end

    cnt=1;
    RTU_test=sort(M_RTU(:,6));
    for i = 1:length(RTU_test)-1
        for j=0:10
            test(cnt)=RTU_test(i)+j*(RTU_test(i+1)-RTU_test(i))/10;
            cnt=cnt+1;
        end
    end
    % Calculating means and variances
    M_PMU_mean=nanmean(M_PMU); M_PMU_var=nanvar(M_PMU);
    M_RTU_mean=nanmean(M_RTU); M_RTU_var=nanvar(M_RTU);

    % Forming the vector of PDFs
    pdf_travtime=[M_PMU_mean' M_PMU_var'; M_RTU_mean' M_RTU_var'];

elseif opt0==2 % IEEE 300 Bus System
    pdf_travtime=zeros(300,2);

    M_Area1_Part1_read=dlmread('Results_300_Bus_Area1_Part1_all.win.txt'); % RTU area
    M_Area1_Part1=zeros(size(M_Area1_Part1_read,1)-1,size(M_Area1_Part1_read,2));
    for i=1:size(M_Area1_Part1_read,2)
        k=2;
        while (k<=size(M_Area1_Part1_read,1))
            cnt=1;
            while (M_Area1_Part1_read(k,i)==0 && k<=size(M_Area1_Part1_read,1)) % check for dropped measurements
                M_Area1_Part1(k,i)=NaN;
                k=k+1;
                cnt=cnt+1;
                if (k>size(M_Area1_Part1_read,1))
                    break;
                end
            end
            if (k<=size(M_Area1_Part1_read,1))
                M_Area1_Part1(k-cnt,i)=M_Area1_Part1_read(k,i)+(cnt-1)*2+(2-M_Area1_Part1_read(k-cnt,i));
                k=k+1;
            end
        end
    end

    M_Area1_Part2_read=dlmread('Results_300_Bus_Area1_Part2_all.win.txt'); % RTU area
    M_Area1_Part2=zeros(size(M_Area1_Part2_read,1)-1,size(M_Area1_Part2_read,2));
    for i=1:size(M_Area1_Part2_read,2)
        k=2;
        while (k<=size(M_Area1_Part2_read,1))
            cnt=1;
            while (M_Area1_Part2_read(k,i)==0 && k<=size(M_Area1_Part2_read,1)) % check for dropped measurements
                M_Area1_Part2(k,i)=NaN;
                k=k+1;
                cnt=cnt+1;
                if (k>size(M_Area1_Part2_read,1))
                    break;
                end
            end
            if (k<=size(M_Area1_Part2_read,1))
                M_Area1_Part2(k-cnt,i)=M_Area1_Part2_read(k,i)+(cnt-1)*2+(2-M_Area1_Part2_read(k-cnt,i));
                k=k+1;
            end
        end
    end

    M_Area2_read=dlmread('Results_300_Bus_Area2_all.win.txt'); % PMU area
    M_Area2=zeros(size(M_Area2_read,1)-1,size(M_Area2_read,2));
    for i=1:size(M_Area2_read,2)
        k=2;
        while (k<=size(M_Area2_read,1))
            cnt=1;
            while (M_Area2_read(k,i)==0 && k<=size(M_Area2_read,1)) % check for dropped measurements
                M_Area2(k,i)=NaN;
                k=k+1;
                cnt=cnt+1;
                if (k>size(M_Area2_read,1))
                    break;
                end
            end
            if (k<=size(M_Area2_read,1))
                M_Area2(k-cnt,i)=M_Area2_read(k,i)+(cnt-1)*0.02+(0.02-M_Area2_read(k-cnt,i));
                k=k+1;
            end
        end
    end

    M_Area3_read=dlmread('Results_300_Bus_Area3_all.win.txt'); % RTU area
    M_Area3=zeros(size(M_Area3_read,1)-1,size(M_Area3_read,2));
    for i=1:size(M_Area3_read,2)
        k=2;
        while (k<=size(M_Area3_read,1))
            cnt=1;
            while (M_Area3_read(k,i)==0 && k<=size(M_Area3_read,1)) % check for dropped measurements
                M_Area3(k,i)=NaN;
                k=k+1;
                cnt=cnt+1;
                if (k>size(M_Area3_read,1))
                    break;
                end
            end
            if (k<=size(M_Area3_read,1))
                M_Area3(k-cnt,i)=M_Area3_read(k,i)+(cnt-1)*2+(2-M_Area3_read(k-cnt,i));
                k=k+1;
            end
        end
    end

    % Calculating means and variances
    M_Area1_Part1_mean=nanmean(M_Area1_Part1);
    M_Area1_Part1_var=nanvar(M_Area1_Part1);

    M_Area1_Part2_mean=nanmean(M_Area1_Part2);
    M_Area1_Part2_var=nanvar(M_Area1_Part2);

    M_Area2_mean=nanmean(M_Area2);
    M_Area2_var=nanvar(M_Area2);

    M_Area3_mean=nanmean(M_Area3);
    M_Area3_var=nanvar(M_Area3);

    % Forming the vector of PDFs
    M_Area1_Part1_cnt=1;
    M_Area1_Part2_cnt=1;
    M_Area2_cnt=1;
    M_Area3_cnt=1;
    for i=1:80
        pdf_travtime(i,1)=M_Area1_Part1_mean(i);
        pdf_travtime(i,2)=M_Area1_Part1_var(i);
        M_Area1_Part1_cnt=M_Area1_Part1_cnt+1;
    end
    for i=81:93
        pdf_travtime(i,1)=M_Area1_Part2_mean(M_Area1_Part2_cnt);
        pdf_travtime(i,2)=M_Area1_Part2_var(M_Area1_Part2_cnt);
        M_Area1_Part2_cnt=M_Area1_Part2_cnt+1;
    end
    for i=94:167
        pdf_travtime(i,1)=M_Area2_mean(M_Area2_cnt);
        pdf_travtime(i,2)=M_Area2_var(M_Area2_cnt);
        M_Area2_cnt=M_Area2_cnt+1;
    end
    for i=168:179
        pdf_travtime(i,1)=M_Area3_mean(M_Area3_cnt);
        pdf_travtime(i,2)=M_Area3_var(M_Area3_cnt);
        M_Area3_cnt=M_Area3_cnt+1;
    end
    pdf_travtime(180,1)=M_Area1_Part2_mean(M_Area1_Part2_cnt);
    pdf_travtime(180,2)=M_Area1_Part2_var(M_Area1_Part2_cnt);
    M_Area1_Part2_cnt=M_Area1_Part2_cnt+1;
    for i=181:185
        pdf_travtime(i,1)=M_Area3_mean(M_Area3_cnt);
        pdf_travtime(i,2)=M_Area3_var(M_Area3_cnt);
        M_Area3_cnt=M_Area3_cnt+1;
    end
    pdf_travtime(186,1)=M_Area1_Part2_mean(M_Area1_Part2_cnt);
    pdf_travtime(186,2)=M_Area1_Part2_var(M_Area1_Part2_cnt);
    M_Area1_Part2_cnt=M_Area1_Part2_cnt+1;
    for i=187:230
        pdf_travtime(i,1)=M_Area3_mean(M_Area3_cnt);
        pdf_travtime(i,2)=M_Area3_var(M_Area3_cnt);
        M_Area3_cnt=M_Area3_cnt+1;
    end
    for i=231:241
        pdf_travtime(i,1)=M_Area1_Part2_mean(M_Area1_Part2_cnt);
        pdf_travtime(i,2)=M_Area1_Part2_var(M_Area1_Part2_cnt);
        M_Area1_Part2_cnt=M_Area1_Part2_cnt+1;
    end
    pdf_travtime(242,1)=M_Area3_mean(M_Area3_cnt);
    pdf_travtime(242,2)=M_Area3_var(M_Area3_cnt);
    M_Area3_cnt=M_Area3_cnt+1;
    for i=243:245
        pdf_travtime(i,1)=M_Area2_mean(M_Area2_cnt);
        pdf_travtime(i,2)=M_Area2_var(M_Area2_cnt);
        M_Area2_cnt=M_Area2_cnt+1;
    end
    pdf_travtime(246,1)=M_Area3_mean(M_Area3_cnt);
    pdf_travtime(246,2)=M_Area3_var(M_Area3_cnt);
    M_Area3_cnt=M_Area3_cnt+1;
    for i=247:262
        pdf_travtime(i,1)=M_Area1_Part2_mean(M_Area1_Part2_cnt);
        pdf_travtime(i,2)=M_Area1_Part2_var(M_Area1_Part2_cnt);
        M_Area1_Part2_cnt=M_Area1_Part2_cnt+1;
    end
    for i=263:265
        pdf_travtime(i,1)=M_Area2_mean(M_Area2_cnt);
        pdf_travtime(i,2)=M_Area2_var(M_Area2_cnt);
        M_Area2_cnt=M_Area2_cnt+1;
    end
    for i=266:300
        pdf_travtime(i,1)=M_Area1_Part2_mean(M_Area1_Part2_cnt);
        pdf_travtime(i,2)=M_Area1_Part2_var(M_Area1_Part2_cnt);
        M_Area1_Part2_cnt=M_Area1_Part2_cnt+1;
    end

end

