function Elip_Plot(modelo,Elip,X)
% Função complementar da Elipsoide.
%

%% Analisando nargin;

if nargin == 1
    error('Algo errado não está certo.')
elseif nargin == 2
    AAA = 'Plot1';
elseif nargin == 3
    AAA = 'Plot2';
else
    error('Algo errado não esta certo.')
end

% Rodando

[SphX, SphY, SphZ] = ellipsoid(Elip.centro(1), ...
    Elip.centro(2), ...
    Elip.centro(3), ...
    Elip.dimensoes(1), ...
    Elip.dimensoes(2), ...
    Elip.dimensoes(3), ...
    30);

scores = modelo.T(:, 1:3);

if strcmpi(AAA, 'Plot1') % Replicar modelo;
    
% Plotar o gráfico 3D dos Scores de PCA
figure;
scatter3(scores(:,1), scores(:,2), scores(:,3), 'filled');
hold on;

% Plotar o elipsoide
surf(SphX, SphY, SphZ, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', 'r');

xlabel('PC1', 'FontSize', 17);
ylabel('PC2', 'FontSize', 17);
zlabel('PC3', 'FontSize', 17);
title('Gráfico 3D dos Scores de PCA com Elipsoide', 'FontSize', 23);

grid on;
grid minor;
set(gca, 'FontSize', 17, 'LineWidth', 1.2); % Deixa grade e rótulos mais visíveis    
    
elseif strcmpi(AAA, 'Plot2') % Utlizar novas amostras;
    
    % Plotar o gráfico 3D dos Scores de PCA
    figure;
    scatter3(scores(:,1), scores(:,2), scores(:,3), 'filled'); % scores completos
    hold on;
    
    % Plotar o elipsoide
    surf(SphX, SphY, SphZ, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', 'r');
    
    % Plotar ScoresT projetados só na PC3
    ScoresT = X * modelo.P(:,1:1:3); % scores apenas na 3ª componente
    scatter3(ScoresT(:,1), ScoresT(:,2), ScoresT(:,3), 60, 'k^', 'filled'); % marcadores pretos triangulares
    
    xlabel('PC1');
    ylabel('PC2');
    zlabel('PC3');
    title('Gráfico 3D dos Scores de PCA com Elipsoide');
    grid on;
    legend({'Scores originais','Elipsoide','ScoresT (PC3)'});
    
else
    error('Algo errado não esta certo.');
    
end

end

