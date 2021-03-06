function [r,u,t,p] = macroproperties_DG_1d(n,nux,E,Wxx,K,Pp,theta,fmodel)
%% Recover Macroscopic Properties
% compute back, fugacity, macroscopic velocities, temperature and pressure.
    % Computing first velocites from the momentum:
    u = nux./n; 
   
% to compute fugacity, temperature and pressure, we need to rely on the
% distribution fucntion that we where are using: MB, FD, BE.

switch theta
    case{-1} % BE
    % If BE: we apply bisection method to the approx BE distribution Eq.
        r = zeros(Pp,K);
        t = zeros(Pp,K);
        p = zeros(Pp,K);
        r_a = 0.001; r_b = 0.99; tol = 1e-7;
        for i = 1:K
            for j = 1:Pp
            if fmodel == 1 % UU Model
            psi = @(r_x) 2*E(i)- ...
                BE(r_x,1.5)*(n(j,i)/BE(r_x,0.5))^3/(2*pi) - n(j,i)*(u(j,i)^2);
            else % == 2, ES Model
            psi = @(r_x) 2*pi*Wxx(j,i)/n(j,i)^3 - BE(r_x,1.5)/(BE(r_x,0.5))^3;
            end
            r_p = bisection(psi,r_a,r_b,tol);
            r(j,i) = r_p;
            t(j,i) = n(j,i)^2/(pi*(BE(r_p,0.5))^2);
            p(j,i) = E(j,i) - 1/2*n(j,i)*(u(j,i)^2);
            end
        end
        
    case{1} % FD
    % if FD: we apply bisection method to the approx FD distribution Eq.
        r = zeros(Pp,K);
        t = zeros(Pp,K);
        p = zeros(Pp,K);
        r_a = 0.001; r_b = 0.99; tol = 1e-7;
        for i = 1:K
            for j = 1:Pp
            if fmodel == 1 % UU Model
            psi = @(r_x) 2*E(i)- ...
                FD(r_x,1.5)*(n(j,i)/FD(r_x,0.5))^3/(2*pi) - n(j,i)*(u(j,i)^2);
            else % == 2, ES Model
            psi = @(r_x) 2*pi*Wxx(j,i)/n(j,i)^3 - FD(r_x,1.5)/(FD(r_x,0.5))^3;
            end
            r_p = bisection(psi,r_a,r_b,tol);
            r(j,i) = r_p;
            t(j,i) = n(j,i)^2/(pi*(FD(r_p,0.5))^2);
            p(j,i) = E(j,i) - 1/2*n(j,i)*(u(j,i)^2);
            end
        end        
    
    case{0} % MB
    % IF MB: the task is much simple.
        t = 4*E./n - 2*u.^2;
        r = n./sqrt(pi.*t);
        p = E - 1/2.*n.*u.^2;
        
    otherwise 
        error('theta can only be: -1, 0, +1 ');
end
    