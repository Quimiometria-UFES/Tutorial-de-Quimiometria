%% Amostras anormais
% BLABLABLA

% Criado: 06/04/2025
% Atualizado: AA/9/01/2025
% Dr. Pedro H. P. da Cunha
% Tommasi Laboratorio

%%

% Limpar tudo por precaução
clear all; clc;

computerName = getenv('COMPUTERNAME');

if strcmp(computerName, 'DESKTOP-0FPF1IU')
    Dados.cdPasta = 'C:\Users\ellisson.paulo\Desktop\Quimiometria\20250203 - 3 - Caixa Magica';
    Dados.cdSalvar = 'C:\Users\ellisson.paulo\Desktop\Quimiometria\20250203 - 3 - Caixa Magica\Salvo';
    Dados.cdFus = 'C:\Users\ellisson.paulo\Desktop\Quimiometria\Funções';
    Dados.cdLib = 'C:\Users\ellisson.paulo\Desktop\Quimiometria\Funções\libPLS_1.95';
    Dados.cdAir = 'C:\Users\ellisson.paulo\Desktop\Quimiometria\Funções\pls_chemometrics';
    Dados.cdExt = 'C:\Users\ellisson.paulo\Desktop\MIR\Extraido';
    Dados.cdMPA = 'C:\Users\ellisson.paulo\Desktop\Quimiometria\Funções\MPA';
elseif strcmp(computerName, 'GOOMY')
    Dados.cdPasta  = 'C:\Users\Pedro\OneDrive\Quimiometria\Tommasi\20250502 - Filtro';
    Dados.cdPCA    = 'C:\Users\Pedro\OneDrive\Quimiometria\IFES Ciencia\GitHub\PCA';
    Dados.cdFus    = 'C:\Users\Pedro\OneDrive\Quimiometria\Funções e Rotinas';
    Dados.cdLib    = 'C:\Users\Pedro\OneDrive\Quimiometria\Funções e Rotinas\libPLS_1.95';
    Dados.cdAir    = 'C:\Users\Pedro\OneDrive\Quimiometria\Funções e Rotinas\pls_chemometrics';
    Dados.cdExt    = 'C:\Users\Pedro\OneDrive\Quimiometria\Tommasi\MIR\Extraido';
    Dados.cdMPA    = 'C:\Users\Pedro\OneDrive\Quimiometria\Funções e Rotinas\MPA-SVR';
else
    error('Computador não identificado.');
end

cd(Dados.cdPasta)
load('Sem média.mat')
load('Out.mat')

cd(Dados.cdPCA);
num    = 1:1:size(X,2);
classX = repmat(1:4, 1, ceil(size(X,2)/4));
classX = classX(1:size(X,2)); % corta o excesso, se houver
modelo = pcamodel(X,{'none'},6,classX,num);

Sample1 = [];
% Modelo modelo.T(:,1:1:3) contém as Scores de n amostras e 3 PCs.
% Em IDs tem o código das n amostras.
% Cada amostra tem 2 a mais amostras, desejo identificar o centro dos
% scores de cada conjunto e a distancia de cada amostra. Depois verificar
% quais são as 5% amostras mais longes dos seus núcleos.

% === 1. Preparação ===
Scores = modelo.T(:, 1:3);  % Scores do PCA (n x 3)
IDs    = string(IDs);       % Vetor com o ID de cada amostra (n x 1)
X      = X;                 % Dados espectrais originais (n x p)

unique_IDs = unique(IDs);
distancias = zeros(size(Scores, 1), 1); % Distância de cada amostra ao centro do grupo
centros    = zeros(length(unique_IDs), 3); % Centroide de cada grupo
Qnt        = zeros(length(unique_IDs), 1); % Quantidade de amostras por grupo

% === 2. Cálculo dos centros e distâncias ===
for i = 1:length(unique_IDs)
    idx           = IDs == unique_IDs(i);
    grupo         = Scores(idx, :);
    centro        = mean(grupo, 1);
    centros(i, :) = centro;
    Qnt(i,1)      = sum(idx);

    dists = vecnorm(grupo - centro, 2, 2); % Distância Euclidiana
    distancias(idx) = dists;
end

% === 3. Identificar top 5% amostras mais distantes ===
[~, ord]     = sort(distancias, 'descend');
n_outliers   = round(0.05 * length(distancias));
outlier_idx  = ord(1:n_outliers);              % índices das outliers
IDs_outliers = unique(IDs(outlier_idx));       % IDs dos grupos com outlier

% === 4. Plot geral ===
for qe = 1:1:size(IDs_outliers,1) % qe = 3;
    
    idx = find(IDs == IDs_outliers(qe));
    
    if ~isempty(Out)
        if any(ismember(idx, Out))
            continue % pula para o próximo qe
        end
    end
    
    close all
    figure('Units','normalized','OuterPosition',[0 0 1 1]);
    
    plot(1:1:1798, X(idx,:));          hold on
    plot(1:1:1798, mean(X), '-.k');
    xlim([-17 1815]);                  ylim([-0.0591 0.6615]);
        
    labels = cellstr(num2str((1:size(idx,1))')); % cria {'1','2',...,'n'}
    labels{end+1} = 'Média de X';                % adiciona média ao final
    legend(labels);                             % aplica a legenda
    
    Select = input('Quais grupos deseja excluir? (ex: 1, 2, [1;3], All, 0): ', 's');
    
    if strcmpi(Select, 'All')
        Out = [Out; idx];                     % exclui todos
    else
        Select = str2num(Select); %#ok<ST2NM>
        
        if isequal(Select, 0)
            % não faz nada
        else
            Out = [Out; idx(Select)];         % exclui só os selecionados
        end
    end
    
    clear idx Select
    
    fprintf('Foi analisado %.1f porcentos.\n', (qe/size(IDs_outliers,1))*100);
    save('Out','Out');
end
