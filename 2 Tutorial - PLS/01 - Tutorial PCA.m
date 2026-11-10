% Rotina para desenvolvimento dos modelos de PCA utilizando dados continuos
% e propriedades fisico-quimicas
% Essa rotna esta difivida nas seguintes partes:
% 01 - Conhecendo o pcamodel
% 02 - Aprimorando o modelo
% 03 - Classificando com base em dados FQ

% Extras:
% 00 - Edicao de figuras
% 00 - Contruindo as figuras do artigo
_______________________________________________________________________________

%%%%%%%%%%%%%% 01 - Conhecendo o pcamodel

% Recomendo comecar a pratica com os seguintes comandos.
clear        % Limpa o Workspace
clc          % Limpa o Command Window
close all    % Fecha qualquer imagem aberta.

cd('...\IFES-Ciencia');
% O comando cd('LOCAL'), funciona como um modificador de folder, ou seja, ele
% muda a pasta que o octave/matlab esta utilizando. Lembrando, caso deseje usar
% funcao não incorporada ao programa terá que modificar para a pasta que a funcao
% se encontra.

% Aqui nesta pasta iremos trazer os dados do espectro infravermelho médio para
% dentro do programa.
load('MIR_data.mat');
% A funcao load tem como acao puxar arquivos .mat, para saber mais utilize o comando:
% help load

% Este arquivo esta no formato '.mat', formato que o matlab utiliza, nele temos
% as seguintes variaveis:
% MIRdata: Espectros MIR, onde 200 e o numero de amostras e 3351 o numero de
% variaveis.
% num:     Comprimento de Onda do espectro MIR.
% y:       vetor y, onde tem a propriedade que desejamos prever, neste caso
% uma propriedade qualificativa com o numero do poco de origem.

% Alem de utilizar .mat tu pode utilizar .asc e .xls para puxar dados, entretanto
% ensinaremos isto mais a frente.

% Primeiramente, caso esteje no Octave, vamos dar puxar os pacotes.
pkg load statistics
pkg load io

% Mundado para a pasta com as funcoes de PCA.
cd('...\IFES-Ciencia\PCA');

% A funcao pcamodel foi desenvolvida para construir modelos de PCA de modo fácil
% e pratico, vamos falar um pouco sobre ela.

% modelo = pcamodel(X,Xpretreat,npc,classX,xaxis,nsamples)
%
% Output
% modelo: Neste output teremos o nosso modelo PCA construido, ele sera necessario
% para aplicacao futuras.
%
% Input
% X :         Matriz X de dados
% Xpretreat : Metodo de pretratamento dos dados.
% npc:        Numero de PC(Componentes principais).
% classX :    Vetor de classes referente as amostras da matriz X.
% xaxis :     Dimensao do eixo-x. Por exemplo, numero de onda.
% nsamples :  Nome das amostras (opcional)
%
% Como no nosso caso não temos um Xpretreat e nem um nsamples, utilizaremos o
% pcamodel da seguinte forma:

Xpretreat = {'none'};
modelo = pcamodel(MIRdata,Xpretreat,5,y,num);
% No lugar de X colocamos MIRdata, pois é nosso espectro MIR, criamos um Xpretreat
% sem tratamento para utilizar como input, definimos npc como 5, classX utilizamos
% o nosso y e xaxis utilizamos o num. Note que não utilizamos um sexto input, que
% deveria ser o nsamples, a funcao consegue compreender a ausencia desse e rodar
% normalmente. Caso deseje saber mais sobre a funcao, incluindo exemplos, utilize
% o seguinte comando.
% help pcamodel

% Abrindo o modelo, ao cliclar nele, no workspace, duas vezes, percemos quais
% variaveis foram construidas. Entre as novas, temos:
% modelo.T:      Scores das amostras.
% modelo.P:      Loading do modelo.
% modelo.varexp: Variancia explicada

% Agora precisamos visualiar a nossa PCA, para isso, utilizaremos o pcaplot.

% pcaplot(modelo,PC1,PC2,PC3,options);
% Input
% modelo:  Modelo desenvolvido pelo pcamodel
% PC1:     Primeira componente principal.
% PC2:     Segunda componente principal.
% PC3:     Terceira componente principal. (Caso queira um grafico 3D.)
% options; Opcoes de configuracao

% Para facilitar, iremos fazer cada imagemd de uma vez:
options.Score = 0;
options.Pareto = 0;
options.Loading = 1;
% Ao colocar "0" em qualquer opcao de grafico impedimos essa imagem de ser gerada,
% assim, neste modo, iremos so construir o grafico dos loadings.
pcaplot(modelo,1,2,options);

% No grafico de Loading temos a possibilidade de observar quais sao as variaveis
% de maior importancia para o modelo.

options.Score = 0;
options.Pareto = 1;
options.Loading = 0;
pcaplot(modelo,1,2,options);

% No grafico de Pareto podemos observar a variancia explicada com base em cada
% Score.

options.Score = 1;
options.Pareto = 0;
options.Loading = 0;
pcaplot(modelo,1,2,options);

% O Grafico de Score é o mais importante para o desenvolvimento da PCA, e nele
% que identificamos se foi possiveis, ou nao, separar as classes.
% No caso apresentado, podemos dizer que a Classe 1 ficou bem separa das demais,
% a Classe 4 esta proxima, todavia separada, do conjunto Classe 2 e 3, e estes
% o modelo não conseguiu distinguir. Além deste grafico Score, temos o grafico
% versao biplot.

options.Score = 2;
options.Pareto = 0;
options.Loading = 0;
pcaplot(modelo,1,2,options);

% Apesar de podermos utilizar o grafico biplot, aqui, nao e recomendado, graficos
% biplot de PCA sao recomendados quanto se tem 15, ou menos, variaveis.

%_______________________________________________________________________________

%%%%%%%%%%%%%% 02 - Aprimorando o modelo.

% Como visto na licao anterior, o PCA não conseguiu obter uma separacao boa de
% todas as classes, entretanto, ainda não extrairmos o maior potencial desta
% tecnica, pois podemos aplicar alguns metodos para aperfeicoar o modelo, como
% pretratamento, selecao de variaveis e deteccao de outlier. Como este é um
% tutorial para leigo, iremos nos aprofundar somente no primeiro.

% Pretratamento,
% O pré-tratamento consiste na correção espectral das amostras para suavizar
% possíveis variações indesejadas (ruídos ou interferentes). Tem como principal
% objetivo ajudar o modelo a extrair as informacoes necessarias para a
% construcao do mesmo. Todavia, deve ser realizada com cuidada para nao remover
% informacoes relevantes.

% Entre as funcoes utilizadas, temos o pretrat, cujo o objetivo é aplicar alguns
% pretratamento em fontes analiticas, podendo ser:
% {'center'}         Centralização na médialog
% {'auto'}           Autoescalonamento dos dados
% {'snv'}            Variação padrão normal.
% {'msc'}            Correção multiplicativa de sinal
% {'deriv',[7,2,1]}  Derivada

%[Xp,Xtp]=pretrat(X,Xt,{'auto'});

% A funcao foi desenvolvida para aplicar o mesmo pretratamento em dois espectros
% ao mesmo tempo, um de calibracao e outro teste, entretanto tu pode fazer uma
% jogada para fazer somente o tratamento de um espectro.

[Xp,~]=pretrat(MIRdata,MIRdata,{'deriv',[7,2,1]});
% Em vez de colocar dois espectros diferentes, colocamos o mesmo como input, mas
% no output colocamos um '~' para não criar este espectro.

% Agora, vamos visualizar como o pretratamento afetou o espectro.
figure(1)
subplot(2,1,1)
plot(num,MIRdata);
subplot(2,1,2)
plot(num,Xp);

% A Derivada é um dos pretratamento mais recomendados para espectros de
% infravermelho, note na figura 1.2 que ele acentua os pontos do espectro que
% apresentam uma curvatura.

% Agora, tu pode aplicar o espectro tratado, Xp, no pcamodel, ou mandar aplicar
% o pretratamento diretamente no pcamodel.

modelo2 = pcamodel(Xp,{'none'},5,y,num); % Lembre-se de sempre informar o
% pretratamento, caso nao queira nenhum coloque o 'none'.
% Xpretreat = {'deriv',[7,2,1]};
% modelo2 = pcamodel(MIRdata,Xpretreat,5,y,num);

options.Score = 1;
options.Pareto = 0;
options.Loading = 0;
pcaplot(modelo2,1,2,options);

% Note que neste novo Grafico Score as amostras ficaram muito mais separadas,
% com limites mais nitidos que no modelo sem tratamento, assim, dessa forma,
% podemos dizer que este modelo ficou mais adequado.

%_______________________________________________________________________________

%%%%%%%%%%%%%% 03 - Classificando com base em dados FQ

% Para obtencao da PCA a partir das propriedades fisico-quimicas, e
% aconselhavel fazer a limpeza das variaveis da memoria do Octave, bem como da
% janela de comandos, alem de fechar janelas abertas, por meio dos comandos:
clc;
clear all;
close all;

cd('...\IFES-Ciencia')
% Alem de utilizar arquivos .mat, podemos utilizar tambem .txt, como este
% Petroleum.txt, entretanto, neste caso e necessario saber o que e o que no
% arquivo para conseguir organizar depois.

% Puxando os dados.
Dados = load('Petroleum.txt'); % Matriz de dados

% Separando as variaveis corretamente.
X = Dados(:,3:end);   % Matriz de propriedades FQ.
y = Dados(:,2);       % Vetor qualitativo de origem dos pocos.
amostra = Dados(:,1); % Numero da amostra.

clear Dados % Limpando para reduzir espaco no Wokspace.

% Este tipo de fonte analitica constuma ter possibilidades de pretratamento
% limitada, normalmente se aplica autoescalonamento.

cd('...\IFES-Ciencia\PCA')
method = {'auto'};
[Xp,~]=pretrat(X,X,method);

figure(1)
subplot(2,1,1)
plot(1:1:size(X,2),X);
subplot(2,1,2)
plot(1:1:size(Xp,2),Xp);
% Ao analisar o conjunto de dados conclui que se trata de um dado discreto,
% por isso, aplique autoescalonamento para deixar igual o desvio padr�o.



% Note, no primeiro grafico, temos as variaveis nao tratadas, algumas tem uma
% faixa consideravelmente ampla, como a variavel 2, variando entre 1.2 a 512.0,
% e outras com faixa curta, como a 8, variando na faixa 11.2 a 12.5. Essa grande
% diferenca na dimensao que nao e ligado diretamente a amostra, mas sim ao
% tipo de propriedade, principalmente devido ao tipo de unidade distintas,
% atrapalha a construcao do modelo, devido a pesos distintos.

% Aplicando o autoescalonamento essa diferenca de dimensao e corrigida, fazendo
% com que cada variavel tenha o mesmo peso.

%method = {'center'};
modelo = pcamodel(X,method,5,y);

% Obtencao dos graficos
close all
options.Score = 2;
options.Pareto = 1;
options.Loading = 1;
pcaplot(modelo,1,2,options);

% No grafico nao percebemos uma separacao nitida das amostras, no maximo a
% Classe 4 se separando das demais devido a PC1 e pelo grafico biplot sabemos
% que as variaveis mais importantes para a PC1, neste caso, sao as variaveis 5,
% 6, 9 e 10 positivamente e 1, 4 e 8 negativamente.

close all
options.Score = 2;
options.Pareto = 1;
options.Loading = 1;
pcaplot(modelo,1,2,3,options); % Adicionado uma terceira PC, podemos construir
% um grafico 3D.

% Neste grafico 3D podemos ver que as classes tem uma separacao melhor entre
% elas, entretanto, ainda assim, nao e o desejado para um modelo ideal.
_______________________________________________________________________________
%%%%%%%%%%%%%% 00 - Edicao de figuras
% Neste tutorial sera ensinado como editar configuracoes das imagens do
% Octave criadas pelo pcaplot.

%% Primeiro, iremos criar o nosso modelo simples PCA.
load('MIR_data.mat');
pretrat = {'msc';'center'};
modelo = pcamodel(MIRdata,pretrat,5,y);

%% Criamos o grafico que desejamos editar.
options.Score = 1;
options.Pareto = 0;
options.Loading = 0;
pcaplot(modelo,1,2,options);

%% Editando Legenda
% O pcaplot cria a legenda automaticamente com o numero de classe, variando
% de 1 até 10, entretanto, isso n�o fica bonito em trabalhos e artigos.
% Logo, o ideal � que troquemos isso. Com a imagem sendo a �nica aberta
% podemos utilizar o seguinte comando.

legend('Poco 1','Poco 2','Poco 3','Poco 4');
% Tu pode substituir a palavra no '' por qualquer palavra.

legend('Location','southwest');
% Com este comando voc� pode substituir o local da legenda, lembrando que
% os comandos podem ser combinados.
%legend('Poco 1','Poco 2','Poco 3','Poco 4','Location','southwest');
% As localizacoes possiveis sao: 'north';'south';'east';'west';'northeast';
%'northwest';'southeast';'southwest';'northoutside';'southoutside';
%'eastoutside';'westoutside';'northeastoutside';'northwestoutside';
%'southeastoutside';'southwestoutside'

%% Editando Eixos
% Outro ponto interessante de se mudar e o nome dos eixos, podemos fazer
% isso utilizando as seguintes funcoes.

ylabel('Score PC2')
xlabel('Score PC1')

% FontSize
% Voc� tambem pode escolher o tamanho da fonte.
ylabel('Score PC2','FontSize',24)
xlabel('Score PC1','FontSize',24)

%% Editando tamanho de texto
% Com este comando tu modifica o texto de toda imagem.
set(gca,'FontSize',20)

%_______________________________________________________________________________
%%%%%%%%%%%%%% 00 - Contruindo as figuras do artigo.
%% DOI: {A espera}
%%

%% Figura 1
clear all
clc

cd('...\IFES-Ciencia');
load('MIR_data.mat');

close all
plot(num,MIRdata); hold on;
set(gca,'FontSize',18,'XDir','reverse');
ylabel('Absorbancia','FontSize',22);
xlabel('Numero de Onda (cm^-^1)','FontSize',22);
xlim([min(num) max(num)]);

savefig(1,"Figura 1")
saveas(1,"Figura 1",'tif')
close (1)

%% Figura 2 a 4
clear all
clc

% Primeiramente, caso esteje no Octave, vamos dar puxar os pacotes.
pkg load statistics
pkg load io

cd('...\IFES-Ciencia');
load('MIR_data.mat');

cd('...\IFES-Ciencia\PCA');

modelo = pcamodel(MIRdata,{'msc';'center'},5,y,num);

close all
options.Score = 1;
options.Pareto = 1;
options.Loading = 1;
pcaplot(modelo,1,2,options);

savefig(1,"Figura 2")
saveas(1,"Figura 2",'tif')
close (1)

savefig(2,"Figura 3")
saveas(2,"Figura 3",'tif')
close (2)

savefig(3,"Figura 4")
saveas(3,"Figura 4",'tif')
close (3)

%% Figura 5 a 7
clear all
clc

% Primeiramente, caso esteje no Octave, vamos dar puxar os pacotes.
pkg load statistics
pkg load io

cd('...\IFES-Ciencia');

Dados = load('Petroleum.txt'); % Matriz de dados
X = Dados(:,3:end);   % Matriz de propriedades FQ.
y = Dados(:,2);       % Vetor qualitativo de origem dos pocos.
amostra = Dados(:,1); % Numero da amostra.
clear Dados

cd('...\IFES-Ciencia\PCA');
pretrat = {'auto'};
modelo = pcamodel(X,pretrat,5,y);

close all
options.Score = 1;
options.Pareto = 0;
options.Loading = 0;
pcaplot(modelo,1,2,options);

savefig(1,"Figura 5")
saveas(1,"Figura 5",'tif')
close (1)

options.Score = 2;
options.Pareto = 1;
options.Loading = 0;
pcaplot(modelo,1,2,options);

savefig(3,"Figura 7") % Salva a figura de modo a poder abrir futuramente.
saveas(3,"Figura 7",'tif') % Salva no formato desejado.
close (3)

savefig(1,"Figura 6")
saveas(1,"Figura 6",'tif')
close (1)

%% Figura 8
clear all
clc

% Primeiramente, caso esteje no Octave, vamos dar puxar os pacotes.
pkg load statistics
pkg load io

cd('...\IFES-Ciencia');

Dados = load('Petroleum.txt'); % Matriz de dados
X = Dados(:,3:end);   % Matriz de propriedades FQ.
y = Dados(:,2);       % Vetor qualitativo de origem dos pocos.
amostra = Dados(:,1); % Numero da amostra.
clear Dados

cd('...\IFES-Ciencia\PCA');
pretrat = {'auto'};
modelo = pcamodel(X,pretrat,5,y);

close all
options.Score = 1;
options.Pareto = 0;
options.Loading = 0;
pcaplot(modelo,1,3,options);

savefig(1,"Figura 8")
saveas(1,"Figura 8",'tif')
close (1)

%% Figura 9
clear all
clc

% Primeiramente, caso esteje no Octave, vamos dar puxar os pacotes.
pkg load statistics
pkg load io

cd('...\IFES-Ciencia');

Dados = load('Petroleum.txt'); % Matriz de dados
X = Dados(:,3:end);   % Matriz de propriedades FQ.
y = Dados(:,2);       % Vetor qualitativo de origem dos pocos.
amostra = Dados(:,1); % Numero da amostra.
clear Dados

cd('...\IFES-Ciencia\PCA');
pretrat = {'auto'};
modelo = pcamodel(X,pretrat,5,y);

close all
options.Score = 1;
options.Pareto = 0;
options.Loading = 0;
pcaplot(modelo,1,3,options);

% Adicionando legenda.
legend('Poco A','Poco B','Poco C','Poco D');

% Editando localizacao da legenda.
legend('Location','southeast');

% Editando o texto interno.
set(gca,'FontSize',16);

% Editando o nome dos eixos.
ylabel('Score PC2','FontSize',18);
xlabel('Score PC1','FontSize',18);

savefig(1,"Figura 9")
saveas(1,"Figura 9",'tif')
close (1)

