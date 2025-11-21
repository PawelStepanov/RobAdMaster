function [omegacherta] = SufficientConditions

global K

% Достаточные условия

phi1 = abs(K(1,1)) * (abs(K(2,2)) + abs(K(1,2))) + abs(K(1,2)) * (abs(K(1,1)) + abs(K(2,1)));
phi2 = abs(K(2,2)) * (abs(K(2,1)) + abs(K(1,1))) + abs(K(2,1)) * (abs(K(2,2)) + abs(K(1,2)));

detK = abs(det(K));

omegacherta = detK / max(phi1, phi2);
end