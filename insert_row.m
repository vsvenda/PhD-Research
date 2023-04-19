% insert_row
% Insert row into matrix
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [matrix_new] = insert_row(matrix_old,position)

colNmb = size(matrix_old,2);
vector = zeros(1,colNmb);
matrix_new = [matrix_old((1:position-1),:); vector; matrix_old((position:end),:)];