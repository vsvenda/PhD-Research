% delete_row
% Delete row in matrix
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

function [matrix_old] = delete_row(matrix_old,position)

matrix_new = [matrix_old((1:position-1),:); matrix_old((position+1:end),:)];
matrix_old=matrix_new;
end