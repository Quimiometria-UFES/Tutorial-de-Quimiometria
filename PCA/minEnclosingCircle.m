function [xc,yc,R] = minEnclosingCircle(P)
% P: matriz Nx2 (x,y)
% Retorna: (xc,yc) centro do círculo mínimo, R raio

n = size(P,1);
R = inf; xc = 0; yc = 0;

for i = 1:n
    for j = i+1:n
        % círculo definido por 2 pontos (diâmetro)
        cx = (P(i,1)+P(j,1))/2;
        cy = (P(i,2)+P(j,2))/2;
        r  = sqrt((P(i,1)-cx)^2+(P(i,2)-cy)^2);
        if all(sqrt((P(:,1)-cx).^2+(P(:,2)-cy).^2) <= r+1e-12)
            if r < R, R = r; xc = cx; yc = cy; end
        end
        
        for k = j+1:n
            % círculo definido por 3 pontos
            A = 2*[P(j,1)-P(i,1), P(j,2)-P(i,2);
                   P(k,1)-P(i,1), P(k,2)-P(i,2)];
            b = [P(j,1)^2-P(i,1)^2+P(j,2)^2-P(i,2)^2;
                 P(k,1)^2-P(i,1)^2+P(k,2)^2-P(i,2)^2];
            if rank(A)==2
                c = A\b;
                cx = c(1); cy = c(2);
                r  = sqrt((P(i,1)-cx)^2+(P(i,2)-cy)^2);
                if all(sqrt((P(:,1)-cx).^2+(P(:,2)-cy).^2) <= r+1e-12)
                    if r < R, R = r; xc = cx; yc = cy; end
                end
            end
        end
    end
end
end
