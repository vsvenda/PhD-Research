% significance_test
% Forming the significance test
% Based on it derive break time (t_break)
% If measurements are not received for t_break sec, the corresponding
% measaurmenet instrument will be denoted as lost (outage)
% Author: Vanja Svenda

function [ t_break ] = significance_test( pdf_travtime )

sig_level=0.01; % Define the significance level
sig_prob=1-sig_level/2;
t_break=zeros(size(pdf_travtime,2),1);

for i=1:size(pdf_travtime,1)
    t_break(i)=norminv(sig_prob,pdf_travtime(i,1),pdf_travtime(i,2));
end
end

