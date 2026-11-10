function [objetos,Xcal,Xtest,ycal,ytest]=caltest(X,y,ncal,alg,rep,method)
% algoritmo para selecionar amostras de calibração e teste.
%      X : matriz de dados espectrais;
%      y : vetor contendo a propriedade de interesse; caso não tenha,
%      utilize []; O vetor y é utilizado para verificação das réplicas.
%   ncal : percentagem de amostras de treinamento; default: 70;
%    alg : tipo de algoritmo a ser utilizado para separação dos dados:
%    kenston('k'); duplex('d') ou segmentado (s); default: 'k'
%    rep : verificação de réplicas: não (0); sim (1); default: 0
% method : método de pre-processamento dos dados antes da separação dos 
%conjuntos de calibração e teste; default: 'none'.
% 
% exemplos:
% [objetos,Xcal,Xtest,ycal,ytest]=caltest(X,y,70,'k',1,{'none'});
% [objetos,Xcal,Xtest,ycal,ytest]=caltest(X,y,60,'d',0,{'center'});
% [objetos,Xcal,Xtest,ycal,ytest]=caltest(X,y,3,'s',1,{'auto'});
% [objetos,Xcal,Xtest,ycal,ytest]=caltest(X,y,3,'s',1);
% [objetos,Xcal,Xtest,ycal,ytest]=caltest(X,y,70);
%
% Paulo R. Filgueiras  - 13/08/2014
% Pedro H. P. da Cunha - 23/10/2025 Aperfeicoamento do Kenston.

if nargin==5,        method={'none'};
elseif nargin==4,    method={'none'};    rep=0;
elseif nargin==3,    method={'none'};    rep=0;    alg='k';
end

if ~isvector(y)
    y=ones(size(X,1),1); rep=0;
end

% pre-processamento dos esepctros.
X2=pretrat(X,[],method);

% verificação das réplicas a partir do vetor y
if rep~=0
    y2.sample=[];y2.sample=[y2.sample;1];
    y2.numero=[];
    for ki=2:size(X2,1)
        if sum(y(ki,:)==y(ki-1,:))==size(y,2)
            y2.numero=ki;
        else
            y2.sample=[y2.sample;ki];
        end
    end
    aa2=y2.sample(2:end)-1;aa2=[aa2;y2.numero];
    y2.sample=[y2.sample,aa2,aa2-y2.sample+1];  % vetor com as posições iniciais e finais para as réplicas.
    clear aa2 ki
    % Calculando a média espectral 
    y2.medioX=[];y2.medioy=[];
    for ki=1:size(y2.sample,1)
        posicao_medio = y2.sample(ki,1):y2.sample(ki,2);
        matriz_medio = mean(X2(posicao_medio,:));
        y2.medioX=[y2.medioX;matriz_medio];       % matriz com os espectros médios.
        y2.medioy=[y2.medioy;y(y2.sample(ki,1))]; % vetor com os espectros médios.
    end
else
    y2.medioX=X2;
    y2.medioy=y;
end
  
%  alg : tipo de algoritmo a ser utilizado para separação dos dados:   
if strcmp(alg,'k')
    ncal     = round(ncal*size(y2.medioX,1)/100);
    objetos2 = kenston(y2.medioX,ncal,1,0,y2.medioy); % não gera gráfico de saída
    objetos2 = sort(objetos2); objetos2=objetos2';
elseif strcmp(alg,'k2')
    ncal=round(ncal*size(y2.medioX,1)/100);
    objetos2=kenston2(y2.medioX,ncal,1,0,y2.medioy); % não gera gráfico de saída
    objetos2=sort(objetos2); objetos2=objetos2';
elseif strcmp(alg,'d')
    ncal=round(ncal*size(y2.medioX,1)/100);
    objetos2=duplex(y2.medioX,size(y2.medioy,1)-ncal);
    objetos2=sort(objetos2);
elseif strcmp(alg,'s')
    aa2=repmat((1:ncal)',size(y2.medioy,1),1); 
    aa2=aa2(1:size(y2.medioy,1)); 
    objetos2=find(aa2~=1);
end
teste2=setxor(1:size(y2.medioy,1),objetos2);
clear aa2

% verificação das réplicas a partir do vetor y para saida das amostras
if rep~=0
    objetos3=[];
    for ki=1:length(objetos2)
        aa2=y2.sample(objetos2(ki),1):y2.sample(objetos2(ki),2);
        objetos3=[objetos3,aa2];
    end
    objetosk=objetos3';
    teste2=setxor(1:size(X,1),objetosk);
    Xcal=X(objetosk,:);
    Xtest=X(teste2,:);
    ycal=y(objetosk,:);
    ytest=y(teste2,:);    
else
    objetosk=objetos2;
    Xcal=X(objetos2,:);
    Xtest=X(teste2,:);
    ycal=y(objetos2,:);
    ytest=y(teste2,:);
end
objetos.cal=objetosk;
objetos.tes=teste2;
objetos.dados=y2;
end

function [object,xm,ym,xt,yt]=kenston(x,no_p,men,pl,y)
%KENSTON  Seleção de subconjunto pelo método Kennard–Stone (otimizado)
% [object,xm,ym,xt,yt]=kenston(x,no_p,men,pl,y)
%
% Entradas (iguais à versão original):
%   x     : (n x m) matriz de preditores
%   no_p  : número de objetos a serem selecionados
%   men   : 1 => 1º ponto mais próximo da média; 0 => mais distante
%   pl    : 1 plota; 0 não plota
%   y     : (n x r) respostas
%
% Saídas (iguais à versão original):
%   object: (1 x no_p) índices dos objetos selecionados
%   xm,ym : subconjunto de calibração
%   xt,yt : subconjunto remanescente (teste)
%
% Observação:
%   Implementação vetorizada e incremental:
%   - Usa 'pdist2' com 'squaredeuclidean' para ganhar velocidade;
%   - Mantém vetor dmin das menores distâncias ao conjunto selecionado;
%   - Atualiza dmin a cada novo ponto sem recomputar tudo.

    % ------------------------
    % Checagens rápidas
    % ------------------------
    if nargin < 5
        error('Uso: [object,xm,ym,xt,yt]=kenston(x,no_p,men,pl,y)');
    end
    [n,m] = size(x);
    if no_p > n
        error('no_p (%d) não pode ser maior que n (%d).', no_p, n);
    end

    % Garante double (pdist2 é mais rápido/seguro em double)
    X = double(x);

    % ------------------------
    % 1) Primeiro ponto (centróide)
    % ------------------------
    mu = mean(X,1);
    d2cent = sum((X - mu).^2, 2);  % distância^2 ao centróide
    if men == 1
        [~, c1] = min(d2cent);     % mais próximo do centróide
    else
        [~, c1] = max(d2cent);     % mais distante do centróide
    end

    object = zeros(1, no_p);
    object(1) = c1;

    if no_p == 1
        % Saídas
        xm = x(object,:);
        ym = y(object,:);
        ind = setdiff((1:n)', object, 'stable');
        xt = x(ind,:);
        yt = y(ind,:);
        if pl==1
            localPlot(X, object);
        end
        return
    end

    % ------------------------
    % 2) Segundo ponto (mais distante do 1º)
    % ------------------------
    D1 = pdist2(X, X(c1,:), 'squaredeuclidean');  % vetor n x 1
    [~, c2] = max(D1);
    object(2) = c2;

    if no_p == 2
        xm = x(object,:);
        ym = y(object,:);
        ind = setdiff((1:n)', object, 'stable');
        xt = x(ind,:);
        yt = y(ind,:);
        if pl==1
            localPlot(X, object);
        end
        return
    end

    % ------------------------
    % 3) Iterações (maximin incremental)
    % Mantém dmin = min dist^2 para o conjunto já selecionado
    % ------------------------
    selected = false(n,1);
    selected(object(1:2)) = true;

    % dmin inicial: min( dist ao c1, dist ao c2 )
    dmin = min(D1, pdist2(X, X(c2,:), 'squaredeuclidean'));
    dmin(selected) = -inf;  % evita re-selecionar

    for k = 3:no_p
        % Pega o candidato que maximiza o mínimo (maximin)
        [~, nxt] = max(dmin);
        object(k) = nxt;
        selected(nxt) = true;

        % Atualiza dmin com a distância ao novo selecionado
        dnew = pdist2(X, X(nxt,:), 'squaredeuclidean');
        dmin = min(dmin, dnew);
        dmin(selected) = -inf;   % bloqueia os já escolhidos
    end

    % ------------------------
    % Saídas
    % ------------------------
    xm = x(object,:);
    ym = y(object,:);
    ind = setdiff((1:n)', object, 'stable');
    xt = x(ind,:);
    yt = y(ind,:);

    % ------------------------
    % Plot opcional (rápido)
    % ------------------------
    if pl==1
        localPlot(X, object);
    end
end

function [model,test]=duplex(X,k)
% -------------------------------------------------------------------------
% Function: [model,test]=duplex(X,k)
% -------------------------------------------------------------------------
% Aim:
% Subset selection with Duplex algorithm; uniform design of model and test
% sets
% -------------------------------------------------------------------------
% Input:
% X, matrix (n,p), predictor variables in columns
% k, number of objects to be selected to test set, (test set can contain 
% at most 0.5n objects. If less objest are selected to test set, than k 
% first objects of the model and test sets are designed uniformly and the
% remaining objects not selected by Duplex algorithm are included 
% into model set)
% -------------------------------------------------------------------------
% Output:
% model, vector (k+(n-k),1), list of objects selected to model set
% test, vector (k,1), list of objects selected to test set (optionally)
% -----------------------------------------------------------------------
% Example: 
% [model,test]=duplex(X,10)
% -----------------------------------------------------------------------
% Reference:
% R.D. Snee, Technometrics 19 (1977) 415-428

% Written by Michal Daszykowski
% Department of Chemometrics, Institute of Chemistry, 
% The University of Silesia
% December 2004

[m,n]=size(X);
ma=floor(0.5*m);

if k>ma
    k=ma;
end

x=[[1:size(X,1)]' X];
n=size(x,2);

% Fist two most distant points to model set
p=tril(fastdist(x(:,2:n),x(:,2:n)));
[i1 i2]=find(p==max(max(p)));
model=x([i1 i2],1);
x([i1 i2],:)=[];

% Another two most distant points to test set
p=tril(fastdist(x(:,2:n),x(:,2:n)));
[i1 i2]=find(p==max(max(p)));
test=x([i1 i2],1);
x([i1 i2],:)=[];


h=waitbar(0,'Please wait ...'); 
h=waitbar(0/k,h);
iter=2;

while length(model)<k
    [ii,ww]=max(min(fastdist(x(:,2:n),X(model,:))));
    model=[model;x(ww,1)];
    x(ww,:)=[]; 
    [ii,ww]=max(min(fastdist(x(:,2:n),X(test,:))));
    test=[test;x(ww,1)];
    x(ww,:)=[];
    iter=iter+1;
    h=waitbar(iter/k,h);
end

if ~isempty(x);
    model=[model;x(:,1)];
end
    
close(h);
end

function D=fastdist(x,y)
% Calculated Euclideam distances between two sets of objetcs
D=((sum(y'.^2))'*ones(1,size(x,1)))+(ones(size(y,1),1)*(sum(x'.^2)))-2*(y*x');
end

function localPlot(X, object)
    [n,m] = size(X);
    if m >= 2
        figure; hold on;
        plot(X(:,1), X(:,2), '.', 'DisplayName','Todos');
        plot(X(object,1), X(object,2), 'r*', 'DisplayName','Selecionados');
        % Anotar índices apenas se n pequeno (evita custo alto de text)
        if n <= 200
            for i=1:n
                text(X(i,1), X(i,2), int2str(i), 'Color',[.3 .3 .3], 'FontSize',7);
            end
        end
        xlabel('Variável 1'); ylabel('Variável 2'); grid on; axis tight;
        legend('Location','best'); title('Kennard–Stone (projeção 2D)');
        hold off;
    else
        figure; hold on;
        plot(X(:,1), X(:,1), '.', 'DisplayName','Todos');
        plot(X(object,1), X(object,1), 'r*', 'DisplayName','Selecionados');
        if n <= 200
            for i=1:n
                text(X(i,1), X(i,1), int2str(i), 'Color',[.3 .3 .3], 'FontSize',7);
            end
        end
        xlabel('Variável 1'); ylabel('Variável 1'); grid on; axis tight;
        legend('Location','best'); title('Kennard–Stone (1D)');
        hold off;
    end
end
