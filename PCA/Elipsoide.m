function [Elip,Out] = Elipsoide(modelo,options)
%Rotina desenvolvida para criar um Elipsoide envolta das amostras do
%pcamodel.

%%Inputs
%modelo = modelo desenvolvido pelo PCA.
%alpha  = taxa de amostras

%%Outputs
% Elip = informações necessarias para criar o gráfico;
% options = ;
%        .graf = 0 sem grafico; 1 com grafico;
%        .alpha = Número de amostras que podem ficar fora;

if nargin == 1    
    options.alpha  = 0.1;
    options.graf   = 1;
    options.center = 3; % Vai considerar quantos PC.
    options.type   = 'normal';
end

if ~isfield(options, 'center')
    options.center = 3;
end

if ~isfield(options, 'type')
    options.type = 'normal';
end

%% Programa
inicio = clock;

% Extraindo opções
graf  = options.graf;
alpha = options.alpha;

if alpha == 1
    error('Alpha não pode ser 1');
end

% Supondo que modelo.T seja uma matriz Nx3 (scores PCA)
scores = modelo.T(:, 1:3);

% Parâmetros
centroM   = mean(scores);               % Centro médio
raio_max  = 0.25;                       % Raio máximo permitido
rng(42);                                   % <-- Define a semente (42 = exemplo fixo)
n_centros = options.center;             % Quantidade de centros a gerar
min_vals  = min(scores);  % Menor valor em cada dimensão (PC1, PC2, PC3)
max_vals  = max(scores);  % Maior valor em cada dimensão (PC1, PC2, PC3)

% Geração de centros dentro da esfera
direcoes     = randn(n_centros, 3);
direcoes     = bsxfun(@rdivide, direcoes, sqrt(sum(direcoes.^2, 2)));
modulos      = rand(n_centros, 1).^(1/3) * raio_max;
desloc       = bsxfun(@times, direcoes, modulos);
poss_centro  = bsxfun(@plus, centroM, desloc);

% Definir o intervalo de margens
margem_range = 0.3:0.01:1;  % Variar de 0.3 a 1 com passo de 0.01
[m1, m2, m3] = meshgrid(margem_range, margem_range, margem_range);
margens_possiveis = [m1(:), m2(:), m3(:)];

Resul{1,1} = NaN; % Margem
Resul{1,2} = Inf; % Volume inicial muito grande
Resul{1,3} = NaN; % Centro

FILTER = size(scores, 1)*alpha;
TOTAL  = size(margens_possiveis,1);
Limpro = ceil(TOTAL * 0.01);  % 0.1% do total

if Limpro < 1000
    Limpro = 1000;
end

if strcmp(options.type, 'normal')
    
    for qe = 1:TOTAL  %qe=1
        margem = margens_possiveis(qe,:);
        
        % Calcular as dimensões apenas uma vez fora do loop interno
        dimensao1 = (max_vals(1) - min_vals(1)) * margem(1);
        dimensao2 = (max_vals(2) - min_vals(2)) * margem(2);
        dimensao3 = (max_vals(3) - min_vals(3)) * margem(3);
        
        % Loop para o centro
        for qi = 1:size(poss_centro,1) %qi=1
            centro = poss_centro(qi,:);
            
            % Chama a função Analise_Elipsoide
            [fora,~,volume] = Analise_Elipsoide(scores, centro, dimensao1, dimensao2, dimensao3);
            
            % Verifica se não há amostras fora
            if size(fora, 1) <= FILTER
                if volume < Resul{1,2} % Verifica se o volume é menor
                    Resul{1,1} = margem;     % Atualiza a margem
                    Resul{1,2} = volume;     % Atualiza o volume
                    Resul{1,3} = centro;     % Atualiza o centro
                end
            end
        end
        
        if mod(qe, Limpro) == 0 || qe == TOTAL
            fprintf("Testamos %d de %d possibilidades.\n", qe, TOTAL);
        end
        
    end
    
elseif strcmp(options.type, 'Ultra')
    
    parfor qe = 1:TOTAL
        margem     = margens_possiveis(qe,:);
        dimensao1  = (max_vals(1) - min_vals(1)) * margem(1);
        dimensao2  = (max_vals(2) - min_vals(2)) * margem(2);
        dimensao3  = (max_vals(3) - min_vals(3)) * margem(3);
        
        bestVolume = inf;
        bestCentro = [];
        bestMargem = [];
        
        for qi = 1:size(poss_centro,1)
            centro = poss_centro(qi,:);
            [fora, ~, volume] = Analise_Elipsoide(scores, centro, dimensao1, dimensao2, dimensao3);
            
            if size(fora,1) <= FILTER && volume < bestVolume
                bestVolume = volume;
                bestCentro = centro;
                bestMargem = margem;
            end
        end
        
        % Salva o resultado parcial
        partialResults{qe} = struct( ...
            'margem', bestMargem, ...
            'volume', bestVolume, ...
            'centro', bestCentro ...
            );
    end
    
    % Escolhe o melhor globalmente
    Resul = {[], inf, []}; % {margem, volume, centro}
    for k = 1:TOTAL
        entry = partialResults{k};
        if ~isempty(entry) && entry.volume < Resul{1,2}
            Resul = {entry.margem, entry.volume, entry.centro};
        end
    end
    
    fprintf('\nFinalizado. Melhor volume: %.4f\n', Resul{1,2});
    
else
    error('Não foi determinado o tipo');
end

if isequal(Resul{1,2}, Inf)
    error('Não foi encontrado um elipsoide possível.');
end


margem = Resul{1,1};     % Atualiza a margem
centro = Resul{1,3};     % Atualiza o centro

dimensao1 = (max_vals(1) - min_vals(1)) * margem(1);
dimensao2 = (max_vals(2) - min_vals(2)) * margem(2);
dimensao3 = (max_vals(3) - min_vals(3)) * margem(3);

% Gerar pontos do elipsoide.
[SphX, SphY, SphZ] = ellipsoid(centro(1), centro(2), centro(3), dimensao1, dimensao2, dimensao3, 30);

[Out, Super_In, volume] = Analise_Elipsoide(scores, centro, dimensao1, dimensao2, dimensao3);

if graf == 1
    
    % Plotar o gráfico 3D dos Scores de PCA
    figure;
    scatter3(scores(:,1), scores(:,2), scores(:,3), 'filled');
    hold on;
    
    % Plotar o elipsoide
    surf(SphX, SphY, SphZ, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', 'r');
    xlabel('PC1');
    ylabel('PC2');
    zlabel('PC3');
    title('Gráfico 3D dos Scores de PCA com Elipsoide');
    grid on;
    
elseif graf == 2
    
    % Plotar o gráfico 3D apenas das amostras selecionadas em 'Out'
    figure;
    scatter3(scores(Out,1), scores(Out,2), scores(Out,3), 'filled'); % <-- somente Out
    hold on;
    
    % Plotar o elipsoide
    surf(SphX, SphY, SphZ, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', 'r');
    xlabel('PC1');
    ylabel('PC2');
    zlabel('PC3');
    title('Gráfico 3D dos Outliers de PCA com Elipsoide');
    grid on;
    
end

%% Salvando

Elip.centro    = centro;
Elip.dimensoes = [dimensao1, dimensao2, dimensao3];
Elip.margem    = margem;
Elip.volume    = volume;
Elip.Out       = Out;
Elip.Super_In  = Super_In;
Elip.options   = options;

tempo_min = etime(clock, inicio) / 60;  % Tempo de execução em minutos
fprintf('A função Analise_Elipsoide demorou %.4f minutos para ser executada.\n', tempo_min);


end

