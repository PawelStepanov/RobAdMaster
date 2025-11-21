function [delta] = MaxZonaUncertaintyStaticCoef

global K
[znak] = ZonaStaticCoeffiecnt;

if znak == 'Знаки поменялись у detmin'
    delta = (sqrt(abs(K(1,1)) * abs(K(2,2))) + sqrt(abs(K(2,1)) * abs(K(1,2)))) / (sqrt(abs(K(1,1)) * abs(K(2,2))) - sqrt(abs(K(2,1)) * abs(K(1,2))))
elseif znak == 'Знаки поменялись у detmax'
    delta = (sqrt(abs(K(1,1)) * abs(K(2,2))) - sqrt(abs(K(2,1)) * abs(K(1,2)))) / (sqrt(abs(K(1,1)) * abs(K(2,2))) + sqrt(abs(K(2,1)) * abs(K(1,2))))
end