function [Elip,Out] = Elipsoide_v2(modelo,options)
% Esta funcao tem como principal objetivo calcular um elipsoide em torno dos
% scores (PC1, PC2 e PC3) de um modelo PCA, de forma automatica, buscando o
% menor volume possivel e permitindo que apenas uma fracao (alpha) das
% amostras fique fora (outliers). Inclui mecanismos para evitar elipsoides
% "colados" em um lado da nuvem (efeito de polo vazio), via penalizacao de
% balanceamento do centro.
%
% [Elip,Out] = Elipsoide_v2(modelo);
% [Elip,Out] = Elipsoide_v2(modelo,options);
%
% Inputs:
%   modelo : estrutura de PCA contendo obrigatoriamente modelo.T (scores).
%            A funcao usa modelo.T(:,1:3) (PC1-3).
%   options: estrutura com parametros (opcional).
%
% Outputs:
%   Elip : estrutura com informacoes do elipsoide e resultados:
%          .centro    -> centro final do elipsoide [1x3]
%          .dimensoes -> semi-eixos [dim1 dim2 dim3]
%          .margem    -> fatores de escala escolhidos [m1 m2 m3]
%          .volume    -> volume do elipsoide encontrado
%          .Out       -> indices das amostras fora (outliers)
%          .Super_In  -> saida auxiliar da Analise_Elipsoide (se aplicavel)
%          .options   -> options utilizadas
%          .custo     -> custo final (volume com penalizacao, quando ativa)
%   Out  : indices das amostras fora do elipsoide (outliers)
%
% Dependencias:
%   - Analise_Elipsoide(scores, centro, dim1, dim2, dim3)
%     Deve retornar: [fora, Super_In, volume]
%
% options = [];
% options.alpha          = 0.10;         % Fracao maxima permitida fora do elipsoide.
%                                        % Ex: 0.01 -> ate 1% fora (mais rigoroso).
%
% options.graf           = 1;            % Controle de grafico:
%                                        % 0 = sem grafico
%                                        % 1 = plota todos os scores + elipsoide
%                                        % 2 = plota apenas os outliers (Out) + elipsoide
%
% options.center         = 20;           % Numero de centros candidatos testados ao redor da media.
%                                        % Maior -> mais chance de solucao, porem mais tempo.
%
% options.type           = 'normal';     % Modo de execucao:
%                                        % 'normal' = for (sequencial)
%                                        % 'Ultra'  = parfor (paralelo, requer toolbox)
%
% options.margin_range   = 0.40:0.01:1.20; % Faixa de margens testadas para cada eixo.
%                                         % A dimensao final de cada eixo = span_robusto * margem.
%                                         % Se alpha for pequeno (ex 0.01), pode precisar > 1.2.
%
% options.robust_prc     = [1 99];       % Percentis usados para definir escala robusta por eixo:
%                                        % span_robusto = p99 - p1 (menos sensivel a outliers extremos).
%
% options.raio_factor    = 0.35;         % Controla o raio da busca de centros candidatos:
%                                        % raio_max = raio_factor * mean(span_robusto).
%                                        % Se alpha for pequeno, aumente (ex 0.7-1.0).
%
% options.lambda_balance = 0.35;         % Peso da penalizacao por desbalanceamento do centro:
%                                        % custo = volume * (1 + lambda_balance * penalidade).
%                                        % 0 desativa penalizacao (pode voltar "polo vazio").
%
% options.min_side_frac  = 0.20;         % Restricao dura (opcional) anti-"polo vazio":
%                                        % Exige que, em cada eixo, exista no minimo essa fracao
%                                        % de pontos acima e abaixo do centro.
%                                        % 0 desativa (recomendado para alpha muito baixo, ex 0.01).
%
% options.seed           = 42;           % Semente aleatoria para reprodutibilidade dos centros candidatos.
%
% Observacoes praticas:
% - Para remover apenas 1% (alpha = 0.01), recomenda-se:
%   options.min_side_frac = 0;
%   options.lambda_balance = 0.45 a 0.70;
%   options.margin_range = 0.30:0.02:2.50;
%   options.raio_factor = 0.70 a 1.00;
%   options.center = 60 a 120.

%% Defaults
if nargin == 1
    options.alpha         = 0.1;      % fração fora permitida
    options.graf          = 1;        % 0 sem plot; 1 plot tudo; 2 plot só Out
    options.center        = 20;       % número de centros candidatos
    options.type          = 'normal'; % 'normal' (for) ou 'Ultra' (parfor)
    options.margin_range  = 0.40:0.01:1.20; % margem mínima maior p/ evitar panqueca
    options.robust_prc    = [1 99];   % percentis usados para escala
    options.raio_factor   = 0.35;     % raio relativo à escala típica
    options.lambda_balance = 0.35;    % peso da penalidade (0 desliga)
    options.min_side_frac = 0.20;     % fração mínima de pontos em cada lado (0 desliga)
    options.seed          = 42;
end

if ~isfield(options,'alpha'), options.alpha = 0.1; end
if ~isfield(options,'graf'), options.graf = 1; end
if ~isfield(options,'center'), options.center = 20; end
if ~isfield(options,'type'), options.type = 'normal'; end
if ~isfield(options,'margin_range'), options.margin_range = 0.40:0.01:1.20; end
if ~isfield(options,'robust_prc'), options.robust_prc = [1 99]; end
if ~isfield(options,'raio_factor'), options.raio_factor = 0.35; end
if ~isfield(options,'lambda_balance'), options.lambda_balance = 0.35; end
if ~isfield(options,'min_side_frac'), options.min_side_frac = 0.20; end
if ~isfield(options,'seed'), options.seed = 42; end

alpha = options.alpha;
graf  = options.graf;

if alpha <= 0 || alpha >= 1
    error('alpha deve estar entre 0 e 1 (exclusivo).');
end

%% Scores PCA (PC1-3)
scores = modelo.T(:,1:3);
N = size(scores,1);
FILTER = N * alpha;

%% Centro base
centroM = mean(scores,1);

%% Escala robusta (percentis) para definir "tamanho típico" por eixo
pLo = options.robust_prc(1);
pHi = options.robust_prc(2);
lo  = prctile(scores, pLo);
hi  = prctile(scores, pHi);
span = hi - lo;

% Evita span ~0 (caso degenerado)
span(span <= eps) = std(scores(:,span <= eps),0,1);
span(span <= eps) = 1;

% Raio adaptativo para centros candidatos
% (usa norma média do span para dar escala global)
raio_max = options.raio_factor * mean(span);

%% Centros candidatos em torno da média
rng(options.seed);
n_centros = options.center;
direcoes = randn(n_centros, 3);
direcoes = bsxfun(@rdivide, direcoes, sqrt(sum(direcoes.^2,2)));
modulos  = rand(n_centros,1).^(1/3) * raio_max;
desloc   = bsxfun(@times, direcoes, modulos);
poss_centro = bsxfun(@plus, centroM, desloc);

%% Margens possíveis (mesh 3D)
margem_range = options.margin_range;
[m1,m2,m3] = meshgrid(margem_range, margem_range, margem_range);
margens_possiveis = [m1(:), m2(:), m3(:)];
TOTAL = size(margens_possiveis,1);

% Progresso
Limpro = ceil(TOTAL * 0.01);
if Limpro < 1000, Limpro = 1000; end

%% Resultado global: {margem, custo, volume, centro}
Resul = {NaN(1,3), Inf, Inf, NaN(1,3)};

lambda_balance = options.lambda_balance;
min_side_frac  = options.min_side_frac;

%% Busca
inicio = clock;

if strcmpi(options.type,'normal')

    for qe = 1:TOTAL
        margem = margens_possiveis(qe,:);

        % Dimensões usando span robusto (p99-p1)
        dimensao1 = span(1) * margem(1);
        dimensao2 = span(2) * margem(2);
        dimensao3 = span(3) * margem(3);

        for qi = 1:size(poss_centro,1)
            centro = poss_centro(qi,:);

            % Restrição: evitar centro "colado" (polo vazio)
            if min_side_frac > 0
                if ~passaMinimoPorLado(scores, centro, min_side_frac)
                    continue;
                end
            end

            [fora,~,volume] = Analise_Elipsoide(scores, centro, dimensao1, dimensao2, dimensao3);

            if size(fora,1) <= FILTER
                pen = 0;
                if lambda_balance > 0
                    pen = penalidadeBalance(scores, centro); % ~0 bom, ~1 ruim
                end
                custo = volume * (1 + lambda_balance * pen);

                if custo < Resul{1,2}
                    Resul{1,1} = margem;
                    Resul{1,2} = custo;
                    Resul{1,3} = volume;
                    Resul{1,4} = centro;
                end
            end
        end
        
        if mod(qe, Limpro) == 0 || qe == TOTAL
            percent = 100 * qe / TOTAL;
            fprintf('\rProgresso: %6.2f %%', percent);
        end
    end

    fprintf('\n');
    
elseif strcmpi(options.type,'Ultra')

    partialResults = cell(TOTAL,1);

    parfor qe = 1:TOTAL
        margem = margens_possiveis(qe,:);

        dimensao1 = span(1) * margem(1);
        dimensao2 = span(2) * margem(2);
        dimensao3 = span(3) * margem(3);

        bestCusto  = inf;
        bestVolume = inf;
        bestCentro = [];
        bestMargem = [];

        for qi = 1:size(poss_centro,1)
            centro = poss_centro(qi,:);

            if min_side_frac > 0
                if ~passaMinimoPorLado(scores, centro, min_side_frac)
                    continue;
                end
            end

            [fora,~,volume] = Analise_Elipsoide(scores, centro, dimensao1, dimensao2, dimensao3);

            if size(fora,1) <= FILTER
                pen = 0;
                if lambda_balance > 0
                    pen = penalidadeBalance(scores, centro);
                end
                custo = volume * (1 + lambda_balance * pen);

                if custo < bestCusto
                    bestCusto  = custo;
                    bestVolume = volume;
                    bestCentro = centro;
                    bestMargem = margem;
                end
            end
        end

        partialResults{qe} = struct('margem',bestMargem,'custo',bestCusto,'volume',bestVolume,'centro',bestCentro);
    end

    for qe = 1:TOTAL
        entry = partialResults{qe};
        if ~isempty(entry) && isfinite(entry.custo) && entry.custo < Resul{1,2}
            Resul = {entry.margem, entry.custo, entry.volume, entry.centro};
        end
    end

else
    error('options.type deve ser "normal" ou "Ultra".');
end

if ~isfinite(Resul{1,2})
    error('Não foi encontrado um elipsoide possível com as restrições atuais.');
end

%% Reconstrução final do melhor elipsoide
margem = Resul{1,1};
centro = Resul{1,4};

dimensao1 = span(1) * margem(1);
dimensao2 = span(2) * margem(2);
dimensao3 = span(3) * margem(3);

[SphX,SphY,SphZ] = ellipsoid(centro(1), centro(2), centro(3), dimensao1, dimensao2, dimensao3, 30);
[Out, Super_In, volume] = Analise_Elipsoide(scores, centro, dimensao1, dimensao2, dimensao3);

%% Plot
if graf == 1
    figure;
    scatter3(scores(:,1), scores(:,2), scores(:,3), 'filled');
    hold on;
    surf(SphX, SphY, SphZ, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', 'r');
    xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
    title('Scores PCA (PC1-3) com Elipsoide (v2)');
    grid on;

elseif graf == 2
    figure;
    scatter3(scores(Out,1), scores(Out,2), scores(Out,3), 'filled');
    hold on;
    surf(SphX, SphY, SphZ, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'FaceColor', 'r');
    xlabel('PC1'); ylabel('PC2'); zlabel('PC3');
    title('Outliers PCA (PC1-3) com Elipsoide (v2)');
    grid on;
end

%% Saída
Elip.centro    = centro;
Elip.dimensoes = [dimensao1, dimensao2, dimensao3];
Elip.margem    = margem;
Elip.volume    = volume;
Elip.Out       = Out;
Elip.Super_In  = Super_In;
Elip.options   = options;
Elip.custo     = Resul{1,2};

tempo_min = etime(clock, inicio) / 60;
fprintf('Elipsoide_v2 demorou %.4f minutos.\n', tempo_min);

end

%% ===== Helpers (mantidos no mesmo arquivo) =====

function ok = passaMinimoPorLado(scores, centro, min_side_frac)
N = size(scores,1);
minCount = ceil(min_side_frac * N);

ok = true;
for qa = 1:3
    nPos = sum(scores(:,qa) > centro(qa));
    nNeg = sum(scores(:,qa) < centro(qa));
    if (nPos < minCount) || (nNeg < minCount)
        ok = false;
        return;
    end
end
end

function pen = penalidadeBalance(scores, centro)
% Penaliza centros que deixam muito mais pontos de um lado do que do outro
% pen ~ 0 (bom/bem centrado), pen -> 1 (ruim/colado)
N = size(scores,1);
acc = 0;
for qo = 1:3
    nPos = sum(scores(:,qo) > centro(qo));
    nNeg = sum(scores(:,qo) < centro(qo));
    acc = acc + abs(nPos - nNeg) / max(1, N);
end
pen = acc / 3;
end