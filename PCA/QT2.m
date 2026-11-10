function [modeloPCA] = QT2(modeloPCA)
% Calculo T²

%   Detailed explanation goes here
% ---- parâmetros / entradas ----
T_scores = modeloPCA.T;        % N x A  (scores das amostras)
A        = size(T_scores,2);% número de componentes retidos (ex.: 3)
N        = size(T_scores,1);% número de amostras na calibração
alpha    = 0.01;            % nível de significância (ex.: 0.01 ou 0.05)

% ---- estimar variâncias dos scores (autovalores do subespaço) ----
% var com flag 0 usa normalização por (N-1), compatível com fórmula F
lambda   = var(T_scores, 0, 1);   % 1 x A

% caso as variâncias sejam praticamente 0 (numérico), proteger:
lambda(lambda <= eps) = eps;

% ---- calcular T^2 para cada amostra ----
% T^2 = sum( t_ia^2 / lambda_a ) ao longo das colunas (componentes)
T2 = sum( (T_scores.^2) ./ lambda , 2 );   % N x 1

% ---- limite de controle (F-approximation) ----
T2_lim = (A*(N-1)/(N-A)) * finv(1-alpha, A, N-A);

% ---- saída (mostrar) ----
fprintf('N = %d, A = %d, alpha = %.3f\n', N, A, alpha);
fprintf('Limite T^2 (F-approx) = %.4f\n', T2_lim);

% Índices das amostras dentro e fora do limite
idx_inside  = T2 <= T2_lim;
idx_outside = T2 > T2_lim;

% Scores e loadings
T_scores = modeloPCA.T;   % N x A
P_load   = modeloPCA.P;   % M x A
X_center = modeloPCA.X;    % Se já fez 'center', senão use modelo.mean

% Reconstrução das amostras pelo PCA
X_hat = T_scores * P_load';

% Q residual para cada amostra
Q = sum((X_center - X_hat).^2, 2);  % N x 1

% Índices dentro e fora de um limite (exemplo usando percentil 99 para Q)
alpha = 0.01; 
Q_lim = prctile(Q, 100*(1-alpha));  % Limite de Q
Qidx_inside  = Q <= Q_lim;
Qidx_outside = Q > Q_lim;

modeloPCA.T2     = T2;
modeloPCA.T2_lim = T2_lim;
modeloPCA.T2_idx = idx_outside; 

modeloPCA.Q2     = Q;
modeloPCA.Q2_lim = Q_lim;
modeloPCA.Q2_idx = Qidx_outside; 

%%

% Seleciona os 3 primeiros scores
S1 = T_scores(:,1);
S2 = T_scores(:,2);
S3 = T_scores(:,3);

% Cria figura
figure(1)
hold on
grid on
view(3)  % visão 3D

% Plota amostras dentro do limite (círculos verdes)
scatter3(S1(idx_inside), S2(idx_inside), S3(idx_inside), 50, 'b', 'filled');

% Plota amostras fora do limite (círculos vermelhos)
scatter3(S1(idx_outside), S2(idx_outside), S3(idx_outside), 50, 'r', 'filled');

% Rótulos
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
title('PCA Scores 3D com limite T^2')
legend('Dentro do limite','Fora do limite')
hold off

% Cria figura 2
figure(2)
hold on
grid on
view(3)

% Plota amostras dentro do limite Q (losangos verdes)
scatter3(S1(Qidx_inside), S2(Qidx_inside), S3(Qidx_inside), 50, 'b', 'd', 'filled');

% Plota amostras fora do limite Q (losangos vermelhos)
scatter3(S1(Qidx_outside), S2(Qidx_outside), S3(Qidx_outside), 50, 'r', 'd', 'filled');

% Rótulos
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
title('PCA Scores 3D com limite Q')
legend('Dentro do limite','Fora do limite')
hold off

end

