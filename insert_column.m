% insert_column
% Insert column into matrix
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [matrix_new] = insert_column(matrix_old,position)


rowNmb=size(matrix_old,1);
vector = zeros(rowNmb,1);
matrix_new = [matrix_old(:,1:position-1) vector matrix_old(:,position:end)];




