% F_matrix
% Creation of F matrix (Transition matrix for Kalman filter)
% Authors: Vanja Svenda, Alex Stankovic and Andrija Saric

  function [F]=F_matrix(J,dP,X,ns,nss)

  global busdata 
 
  nbus=length(busdata(:,1));
  kb=busdata(:,2);
  
  F=inv(J);

  for n=1:length(dP)
      if X(n)==0
         de_jacob(n)=dP(n)*1e5;
      else
         de_jacob(n)=dP(n)/X(n);
      end
      for k=1:size(F(:,1)) 
          F(k,n)=F(k,n)*de_jacob(n);
      end
  end

  F=F+eye(length(dP));

% Expanding F matrix with variables contained in F matrix but not in
% initial F matrix
  for n=1:nbus
      nn=nbus-ns+n;
      if kb(n)==1
         F=insert_column(F,nn);
         F=insert_row(F,nn);
         F(nn,nn)=1;
      end
      if kb(n)==2
         F=insert_column(F,nn);
         F=insert_row(F,nn);
         F(nn,nn)=1;
      end
  end
