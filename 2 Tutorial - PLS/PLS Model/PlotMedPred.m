function PlotMedPred(m0d,R)
% Função para criar grafico padrão de médido e predito.
% m0d: modelo que tu utilizou, compativel com pldmodel.
% R  : Quantos números arredondar depois da virgula.
%
% Pré-Requisito para o m0d ser valido:
% m0d.RMSEC : Valor do RMSEC
% m0d.RMSECV: Valor do RMSECV
% m0d.RMSEP : Valor do RMSEP
% m0d.R2c   : Valor do R2c
% m0d.R2cv  : Valor do R2cv
% m0d.R2p   : Valor do R2p
% m0d.Ycal  : Matriz com vetor y medido e y predito de calibração.
% m0d.Ycv   : Matriz com vetor y medido e y predito de cross-validation.
% m0d.Ytest : Matriz com vetor y medido e y predito de teste.
%
%
% Dr. Pedro H. P. da Cunha
% Versão 1.3 04/11/2025 Brasil

%% === Validação dos parâmetros de entrada ===
% 1. Verifica se m0d foi passado e é uma struct
if nargin < 1 || ~isstruct(m0d)
    error('Parâmetro "m0d" ausente ou inválido. Deve ser uma estrutura (struct).');
end

% 2. Verifica se R foi passado e é numérico
if nargin < 2 || ~isnumeric(R) || isempty(R) || R < 0
    error('Parâmetro "R" ausente ou inválido. Deve ser um número inteiro ? 0.');
end

% 3. Campos obrigatórios no modelo
camposNecessarios = {'RMSEC','RMSECV','RMSEP','R2c','R2cv','R2p','Ycal','Ycv','Ytest'};
faltando = camposNecessarios(~isfield(m0d, camposNecessarios));

if ~isempty(faltando)
    error('O modelo "m0d" está incompleto. Campos faltando: %s', strjoin(faltando, ', '));
end

% 4. Verifica se os campos numéricos realmente contêm valores válidos
camposNumericos = {'RMSEC','RMSECV','RMSEP','R2c','R2cv','R2p'};
for i = 1:numel(camposNumericos)
    valor = m0d.(camposNumericos{i});
    if ~isnumeric(valor) || isempty(valor) || any(isnan(valor))
        error('Campo "%s" em m0d inválido: deve conter um valor numérico.', camposNumericos{i});
    end
end

% 5. Verifica se Ycal, Ycv e Ytest são matrizes numéricas com 2 colunas
conjuntos = {'Ycal','Ycv','Ytest'};
for i = 1:numel(conjuntos)
    matriz = m0d.(conjuntos{i});
    if ~isnumeric(matriz) || size(matriz,2) ~= 2
        error('Campo "%s" deve ser uma matriz numérica com duas colunas (y medido e y predito).', conjuntos{i});
    end
end

%% Aplicando a função.

RMSEC  = round(m0d.RMSEC,R);
RMSECV = round(m0d.RMSECV,R);
RMSEP  = round(m0d.RMSEP,R);
R2C    = round(m0d.R2c,3);
R2CV   = round(m0d.R2cv,3);
R2P    = round(m0d.R2p,3);

Ycal = round(m0d.Ycal,R);
Ytes = round(m0d.Ytest,R);

Y    = [Ycal;Ytes];
maxY = max(max(Y));
minY = min(min(Y));
difY = maxY - minY;

Lim = [minY-difY*0.05 maxY+difY*0.05];

%close all
% Pega o tamanho da tela [left bottom width height]
screenSize = get(0, 'ScreenSize');
largura     = screenSize(3);
altura      = screenSize(4);
ladoMenor   = min(largura, altura);
fig = figure('Position', [-10,-10, ladoMenor, ladoMenor]);

% Gráfico medido x predito
hold on
plot(Lim, Lim, 'k--', 'LineWidth', 1.2, 'HandleVisibility','off'); % Linha 1:1 fora da legenda
plot(Ycal(:,1),Ycal(:,2), 'bo', 'DisplayName','Calibration', 'MarkerSize', 10, 'LineWidth', 2);
plot(Ytes(:,1),Ytes(:,2), 'r*', 'DisplayName','Evaluation', 'MarkerSize', 10, 'LineWidth', 2);
xlim(Lim);
ylim(Lim);
xlabel('Measured','FontSize',29)
ylabel('Prediction','FontSize',29)
legend('FontSize', 31, 'Location', 'northwest'); % Legenda formatada
set(gca, 'FontSize', 23);

% Limites dos eixos
XL = xlim;
YL = ylim;

% Define o texto
infoText = {
    sprintf('RMSEC  = %.2f', RMSEC)
    sprintf('RMSECV = %.2f', RMSECV)
    sprintf('RMSEP  = %.2f', RMSEP)
    sprintf('R²C    = %.2f', R2C)
    sprintf('R²CV   = %.2f', R2CV)
    sprintf('R²P    = %.2f', R2P)
    };

% Posição no canto inferior direito (5% acima e 5% à esquerda da borda)
xPos = XL(2) - 0.05 * range(XL);
yPos = YL(1) + 0.05 * range(YL);

% Mostra o texto
text(xPos, yPos, infoText, ...
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 29, 'FontName', 'Arial');
hold off

end

