function modelo = pcamodel(X,Xpretreat,Xt,npc,classX,xaxis,nsamples)
% Modelo PCA - Análise por Componentes Principais
% input
% X : Matriz X de dados
% Xpretreat : Método de pretratamento dos dados.
% Xt : matriz de teste,se houver. Caso não tenha, adicione [];
% npc : número de componentes principais a serem mostrados graficamente.
% classX : vetor de classes referente às amostras da matriz X.
% xaxis : dimensão do eixo-x. Por exemplo, número de onda.
% nsamples : nome das amostras (opcional)
%
% output
% modelo : Estrutura contendo as principais informações do modelo PCA.
%
% Exemplo de utilização da rotina:
% modelo = pcamodel(Xcal,{'center'},Xtest,5,classX,xaxis,nsamples)
% modelo = pcamodel(Xcal,{'center'},Xtest,5,classX,xaxis)
% modelo = pcamodel(Xcal,{'auto'},[],5,classX,xaxis)
% modelo = pcamodel(Xcal,{'msc'},[],5,classX)
% modelo = pcamodel(Xcal,{'deriv';[7,2,1]})
%
% Paulo R. Filgueiras - 20/07/2014
%
modelo.data=date;
modelo.X=X;
modelo.Xpretreat=[];
modelo.xaxis=[];
modelo.T=[];
modelo.P=[]; 
modelo.varexp=[]; 
modelo.Ttest=[];
modelo.classX=[];
modelo.nsamples=[];
% modelo = pcamodel(X,Xpretreat,Xt,npc,classX,xaxis,nsamples)
if nargin==1 
    Xpretreat={'center'};
    Xt=[];
    if size(X,2)<10;  npc=size(X,2); else npc=10; end
    xaxis=1:size(X,2);
    nsamples=1:size(X,1);
end

if nargin==2; 
    Xt=[];
    if size(X,2)<10;  npc=size(X,2); else npc=10; end
    xaxis=1:size(X,2);
    nsamples=1:size(X,1);
end
modelo.Xpretreat=Xpretreat;

if nargin==3; 
    if size(X,2)<10;  npc=size(X,2); else npc=10; end
    xaxis=1:size(X,2);
    nsamples=1:size(X,1);
end

if nargin>5; modelo.xaxis=xaxis; end
if nargin<7,  nsamples=1:size(X,1); end
modelo.nsamples=nsamples;

% construção do modelo PCA
if size(X,2)==size(Xt,2)
    [X,Xt]=pretrat(X,Xt,Xpretreat);  % preprocessamento dos dados X
    [modelo.T,modelo.P,modelo.varexp]=pca(X,npc); % Subfunction PCA
    modelo.Ttest=Xt*modelo.P;
else
    X=pretrat(X,[],Xpretreat);  % preprocessamento dos dados X
    [modelo.T,modelo.P,modelo.varexp]=pca(X,npc); % Subfunction PCA
end

%% Gráficos
% -------Figura 1---------------------------
if npc<10 && size(X,2)>10; 
    npc2=10; 
else
    npc2=npc; 
end

figure(1); bar(modelo.varexp(1:npc2,2),0.8), hold on
plot(1:npc2,modelo.varexp(1:npc2,3),'k.'), hold on
plot(1:npc2,modelo.varexp(1:npc2,3),'k'), hold off
xlabel('Componente Principal','FontSize',14)
ylabel('Variância Explicada (%)','FontSize',14)

% -------Figura 2---------------------------
figure(2) % Gráfico dos loadings 
if nargin<6 || ~isvector(xaxis) 
    xaxis=1:size(modelo.X,2); 
end
subplot(2,1,1); plot(xaxis,mean(modelo.X),'k','LineWidth',1);
ylabel('Absorbancia','FontSize',14)
subplot(2,1,2)
if npc==2
    plot(xaxis,modelo.P(:,1),'b'), hold on;  
    plot(xaxis,modelo.P(:,2),'r'), hold off;
    p1=sprintf('Load PC 1 (%0.2f)',modelo.varexp(1,2));  
    p2=sprintf('Load PC 2 (%0.2f)',modelo.varexp(2,2));  
    legend(p1,p2);
elseif npc==3
    plot(xaxis,modelo.P(:,1),'b'), hold on;
    plot(xaxis,modelo.P(:,2),'r'), hold on;
    plot(xaxis,modelo.P(:,3),'k'), hold off;
    p1=sprintf('Load PC 1 (%0.2f)',modelo.varexp(1,2));  
    p2=sprintf('Load PC 2 (%0.2f)',modelo.varexp(2,2));  
    p3=sprintf('Load PC 3 (%0.2f)',modelo.varexp(3,2));  
    legend(p1,p2,p3);
elseif npc==4
    plot(xaxis,modelo.P(:,1),'b'), hold on;
    plot(xaxis,modelo.P(:,2),'r'), hold on;
    plot(xaxis,modelo.P(:,3),'k'), hold on;
    plot(xaxis,modelo.P(:,4),'m'), hold off;
    p1=sprintf('Load PC 1 (%0.2f)',modelo.varexp(1,2));  
    p2=sprintf('Load PC 2 (%0.2f)',modelo.varexp(2,2));  
    p3=sprintf('Load PC 3 (%0.2f)',modelo.varexp(3,2));  
    p4=sprintf('Load PC 4 (%0.2f)',modelo.varexp(4,2));  
    legend(p1,p2,p3,p4);
elseif npc>4
    plot(xaxis,modelo.P(:,1),'b'), hold on;
    plot(xaxis,modelo.P(:,2),'r'), hold on;
    plot(xaxis,modelo.P(:,3),'k'), hold on;
    plot(xaxis,modelo.P(:,4),'m'), hold on;
    plot(xaxis,modelo.P(:,5),'c'), hold off;
    p1=sprintf('Load PC 1 (%0.2f)',modelo.varexp(1,2));  
    p2=sprintf('Load PC 2 (%0.2f)',modelo.varexp(2,2));  
    p3=sprintf('Load PC 3 (%0.2f)',modelo.varexp(3,2));  
    p4=sprintf('Load PC 4 (%0.2f)',modelo.varexp(4,2));  
    p5=sprintf('Load PC 5 (%0.2f)',modelo.varexp(5,2)); 
    legend(p1,p2,p3,p4,p5);
end    
  
hline(0,'k:');
xlabel('Número de onda cm^-^1','FontSize',14)
ylabel('Loadings','FontSize',14)

% -------Figura 3---------------------------
if size(X,2)==size(Xt,2)  % Gráfico dos scores com matriz de teste
    figure(3),plot(modelo.T(:,1),modelo.T(:,2),'k.','MarkerSize',6), hold on
    for ki=1:size(X,1)
        if isnumeric(nsamples), text(modelo.T(ki,1),modelo.T(ki,2),num2str(nsamples(ki)),'FontSize',12);
        else text(modelo.T(ki,1),modelo.T(ki,2),nsamples{ki},'FontSize',12);
        end
    end
    plot(modelo.Ttest(:,1),modelo.Ttest(:,2),'r.','MarkerSize',6), hold on
    for ki=1:size(Xt,1)
        p1=text(modelo.Ttest(ki,1),modelo.Ttest(ki,2),strcat('t',num2str(ki)),'FontSize',12);
        set(p1,'Color','r');
    end
    hline(0,'k:'),vline(0,'k:');
    t1=sprintf('Scores PC 1 (%0.2f)',modelo.varexp(1,2));  xlabel(t1,'FontSize',14)
    t2=sprintf('Scores PC 2 (%0.2f)',modelo.varexp(2,2));  ylabel(t2,'FontSize',14)
else  % Gráfico dos scores sem matriz de teste
    figure(3),plot(modelo.T(:,1),modelo.T(:,2),'k.','MarkerSize',6)
    hline(0,'k:'),vline(0,'k:');
    for ki=1:size(X,1)
        if isnumeric(nsamples), text(modelo.T(ki,1),modelo.T(ki,2),num2str(nsamples(ki)),'FontSize',12);
        else text(modelo.T(ki,1),modelo.T(ki,2),nsamples{ki},'FontSize',12);
        end
    end
    t1=sprintf('Scores PC 1 (%0.2f)',modelo.varexp(1,2));  xlabel(t1,'FontSize',14)
    t2=sprintf('Scores PC 2 (%0.2f)',modelo.varexp(2,2));  ylabel(t2,'FontSize',14)
end

% -------Figura 4---------------------------
if nargin>=5 && size(X,1)==size(classX,1)
    modelo.classX=classX;
    if size(X,2)==size(Xt,2)
        Ttest=[modelo.T;modelo.Ttest];
        classXt=(max(classX)+1)*ones(size(Xt,1),1);
        classX2=[classX;classXt];
        grafico_score(Ttest,classX2,modelo.varexp);  % Gráfico dos scores com amostras de teste.
    else
        grafico_score(modelo.T,classX,modelo.varexp);  % Gráfico dos scores sem amostras de teste.
    end
end
  

% ------------  Tabela  -----------------------
disp('  ')
disp('Porcentagem de variância explicada pelo modelo PCA   ')
disp('  ')
disp('           -----Matri X-----    ')
disp('   PC #    Varexp     Total     ')
disp('   ----    -------   -------    ')
format = '   %3.0f     %6.2f    %6.2f ';
for ki = 1:npc
  tab = sprintf(format,modelo.varexp(ki,:)); disp(tab)
end
disp('  ')

% Sub-rotinas

function [T,P,varexp] = pca(X,npc)
%  Análise por Componentes Principais por SVD
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


function grafico_score(T,classX,varexp)
% sub-rotina para fazer o gráfico dos scores
[a1,classes]=confusionmat(classX,classX);

figure(4)
if length(classes)==1
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1)); 
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    legend(d1)
elseif length(classes)==2
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1)); 
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold off
    legend(d1,d2)
elseif length(classes)==3
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold off
    legend(d1,d2,d3)
elseif length(classes)==4
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,1),x4(:,2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold off
    legend(d1,d2,d3,d4)
elseif length(classes)==5
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,1),x4(:,2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,1),x5(:,2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold off
    legend(d1,d2,d3,d4,d5)
elseif length(classes)==6
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));    
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,1),x4(:,2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,1),x5(:,2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,1),x6(:,2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold off
    legend(d1,d2,d3,d4,d5,d6)    
elseif length(classes)==7
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));    
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));    
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,1),x4(:,2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,1),x5(:,2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,1),x6(:,2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,1),x7(:,2),'k*','LineWidth',1,'MarkerSize',8), hold off
    legend(d1,d2,d3,d4,d5,d6,d7)  
elseif length(classes)==8
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));    
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));    
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));  
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,1),x4(:,2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,1),x5(:,2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,1),x6(:,2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,1),x7(:,2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,1),x8(:,2),'r+','LineWidth',1,'MarkerSize',8), hold off
    legend(d1,d2,d3,d4,d5,d6,d7,d8)            
elseif length(classes)==9
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));    
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));    
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));  
    c9=find(classX==classes(9));   x9=T(c9,:);   d9=sprintf('Classe %g',classes(9)); 
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,1),x4(:,2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,1),x5(:,2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,1),x6(:,2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,1),x7(:,2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,1),x8(:,2),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot(x9(:,1),x9(:,2),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold off
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9)                
elseif length(classes)==10
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));    
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));    
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));  
    c9=find(classX==classes(9));   x9=T(c9,:);   d9=sprintf('Classe %g',classes(9)); 
    c10=find(classX==classes(10)); x10=T(c10,:); d10=sprintf('Classe %g',classes(10)); 
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,1),x4(:,2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,1),x5(:,2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,1),x6(:,2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,1),x7(:,2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,1),x8(:,2),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot(x9(:,1),x9(:,2),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    plot(x10(:,1),x10(:,2),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold off
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10)     
end

hline(0,'k:'),vline(0,'k:');
t1=sprintf('Scores PC 1 (%0.2f)',varexp(1,2));  xlabel(t1,'FontSize',14)
t2=sprintf('Scores PC 2 (%0.2f)',varexp(2,2));  ylabel(t2,'FontSize',14)


function h = hline(y,lc)
[m,n] = size(y);
v = axis;
if ishold
  for ii=1:m
    h(ii) = plot(v(1:2),[1 1]*y(ii,1),lc);
  end
else
  hold on
  for ii=1:m
    h(ii) = plot(v(1:2),[1 1]*y(ii,1),lc);
  end
  hold off
end

if nargout == 0;
  clear h
end

function h = vline(x,lc)
[m,n] = size(x);
if m>1&n>1
  error('Error - input must be a scaler or vector')
elseif n>1
  x   = x';
  m   = n;
end

v     = axis;
if ishold
  for ii=1:m
    h(ii) = plot([1 1]*x(ii,1),v(3:4),lc);
  end
else
  hold on
  for ii=1:m
    h(ii) = plot([1 1]*x(ii,1),v(3:4),lc);
  end
  hold off
end

if nargout == 0;
  clear h
end


