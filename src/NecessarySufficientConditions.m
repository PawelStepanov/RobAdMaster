function [omegamax, omegacherta, conditions] = NecessarySufficientConditions

global K

% Необходимые и достаточные условия

C = inv(K);

p1 = [abs(abs(K(1,1)) * C(1,2) + abs(K(1,2)) * C(2,2)) - (abs(K(1,1)) * C(1,1) + abs(K(1,2)) * C(2,1)) abs(-abs(K(1,1)) * C(1,2) + abs(K(1,2)) * C(2,2)) - (-abs(K(1,1)) * C(1,1) + abs(K(1,2)) * C(2,1)) abs(-abs(K(1,1)) * C(1,2) - abs(K(1,2)) * C(2,2)) - (-abs(K(1,1)) * C(1,1) - abs(K(1,2)) * C(2,1)) abs(abs(K(1,1)) * C(1,2) - abs(K(1,2)) * C(2,2)) - (abs(K(1,1)) * C(1,1) - abs(K(1,2)) * C(2,1))];
p2 = [abs(abs(K(2,1)) * C(1,1) + abs(K(2,2)) * C(2,1)) - (abs(K(2,1)) * C(1,2) + abs(K(2,2)) * C(2,2)) abs(-abs(K(2,1)) * C(1,1) + abs(K(2,2)) * C(2,1)) - (-abs(K(2,1)) * C(1,2) + abs(K(2,2)) * C(2,2)) abs(-abs(K(2,1)) * C(1,1) - abs(K(2,2)) * C(2,1)) - (-abs(K(2,1)) * C(1,2) - abs(K(2,2)) * C(2,2)) abs(abs(K(2,1)) * C(1,1) - abs(K(2,2)) * C(2,1)) - (abs(K(2,1)) * C(1,2) - abs(K(2,2)) * C(2,2))];

phi1_max = max(p1);
phi2_max = max(p2);

omegamax = 1 / max(phi1_max, phi2_max);

[omegacherta] = SufficientConditions;

if round(omegamax,3) == round(omegacherta,3)
    conditions = ['Необходимые и достаточные условия совпадают'];
else
    conditions = ['Необходимые и достаточные условия не совпадают'];
end