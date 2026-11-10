function [xc,yc,zc,R] = minEnclosingSphere(P)
% P: Nx3 pontos
% Retorna: centro (xc,yc,zc) e raio R

% Centro aproximado: centroide
xc = mean(P(:,1));
yc = mean(P(:,2));
zc = mean(P(:,3));

% Raio: distância máxima do centroide até os pontos
R = max(sqrt((P(:,1)-xc).^2 + (P(:,2)-yc).^2 + (P(:,3)-zc).^2));
end
