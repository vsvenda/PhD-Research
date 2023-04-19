% line_index
% Line index
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [index]=line_index(linedata,node_1,node_2)

index=find((linedata(:,2)==node_2 & linedata(:,1)==node_1)|(linedata(:,1)==node_2 & linedata(:,2)==node_1));
