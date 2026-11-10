function modelo = pcamodel(X,Xpretreat,npc,classX,xaxis,nsamples)
% Modelo PCA - Analise por Componentes Principais
% input
% X :         Matriz X de dados
% Xpretreat : Metodo de pretratamento dos dados.
% npc:        Numero de PC(Componentes principais).
% classX :    Vetor de classes referente as amostras da matriz X.
% xaxis :     Dimensao do eixo-x. Por exemplo, numero de onda.
% nsamples :  Nome das amostras (opcional)
%
% output
% modelo : Estrutura contendo as principais informacoes do modelo PCA.
% modelo.T      = [];
% modelo.P      = [];
% modelo.varexp = [];
%
% Exemplo de utilizacao da rotina:
% modelo = pcamodel(Xcal,{'center'},5,classX,xaxis,nsamples)
% modelo = pcamodel(Xcal,{'center'},5,classX,xaxis)
% modelo = pcamodel(Xcal,{'auto'},5,classX)
% modelo = pcamodel(Xcal,{'msc'},5)
% modelo = pcamodel(Xcal,{'deriv';[7,2,1]})
% modelo = pcamodel(modelo,Xtest); Calculando amostras teste.
%
% Pedro Henrique Pereira da Cunha - 10/06/2022
%
modelo.data=date;
modelo.X=[];
modelo.Xpretreat=[];
modelo.xaxis=[];
modelo.T=[];
modelo.P=[];
modelo.varexp=[];
modelo.classX=[];
modelo.nsamples=[];
Finalizar = 1;
% modelo = pcamodel(X,Xpretreat,Xt,npc,classX,xaxis,nsamples)

if nargin==1 % So com X;
    Xpretreat={'none'};
end

if nargin==2 % So com X e Xpretreat ou modelo e Xtest
    if isstruct(X)
       modelo = X;
       Xt = Xpretreat;
       Xt2=pretrat(Xt,[],modelo.Xpretreat);
       modelo.Ttest=Xt2*modelo.P;
       Finalizar = 000;
    else

    if size(X,2)<10  %Definir numero maximo de npc
        npc=[size(X,2)-1];
    else
        npc=10;
    end
    end
end

if Finalizar ~= 000

if nargin<5
    modelo.xaxis=1:1:size(X,2);
else
    modelo.xaxis=xaxis;
end

if nargin<6
    nsamples=1:size(X,1);
end

modelo.Xpretreat=Xpretreat;
modelo.classX=classX;
modelo.nsamples=nsamples;
modelo.npc = npc;

%% Construcao do modelo PCA
    X=pretrat(X,[],Xpretreat);  % preprocessamento dos dados X
    [modelo.T,modelo.P,modelo.varexp]=pca(X,npc); % Subfunction PCA
    modelo.X=X;
end
%% ------------  Tabela  -----------------------
disp('  ')
disp('Porcentagem de variancia explicada pelo modelo PCA   ')
disp('  ')
disp('           -----Matri X-----    ')
disp('   PC #    Varexp     Total     ')
disp('   ----    -------   -------    ')
format = '   %3.0f     %6.2f    %6.2f ';
for ki = 1:modelo.npc
  tab = sprintf(format,modelo.varexp(ki,:)); disp(tab);
end
disp('  ')

% Sub-rotinas

function [T,P,varexp] = pca(X,npc)
%  An�lise por Componentes Principais por SVD
[n,m] = size(X);
if m < n
  cov = (X'*X);
  [u,s,v] = svd(cov);
  PCnumber = (1:m)';
else
  cov = (X*X');
  [u,s,v] = svd(cov);
  v = X'*v;
  for i = 1:n
    v(:,i) = v(:,i)/norm(v(:,i));
  end
  PCnumber = (1:n)';
end
individualExpVar = diag(s)*100/(sum(diag(s)));
varexp  = [PCnumber individualExpVar cumsum(individualExpVar)];
P  = v(:,1:npc);
T = X*P;
