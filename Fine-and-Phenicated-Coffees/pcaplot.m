function pcaplot(modelo,nvar,nplot,nsamples)
% Rotina para fazer gráficos biplot(scores e loadings) 2D e 3D
% input
% modelo: modelo de saida da rotina pcamodel.
%   nvar : variável contendo o nome das variáveis da matrix X.
%  nplot : número de gráficos a serrem feitos ou vetor contendo o número 
%          das componentes principais a serem plotadas.
%  2 : plot 2D ou [1,2]
%  3 : plot 3D ou [1,2,3]
% nsamples : nome das amostras (opcional)
% 
% Paulo R. Filgueiras  -  25/07/2014
%

if nargin<4,    nsamples=1:size(modelo.X,1);  end
if isscalar(nplot),    nplot=1:nplot;   end    % nplot agora é um vetor com as componentes a serem plotadas.

if size(modelo.T,2)==size(modelo.Ttest,2)
    score_train = modelo.T(:,nplot);
    score_test  = modelo.Ttest(:,nplot);
    load_train  = modelo.P(:,nplot);
    t1=sprintf('Scores PC %g (%0.2f)',nplot(1),modelo.varexp(nplot(1),2));
    t2=sprintf('Scores PC %g (%0.2f)',nplot(2),modelo.varexp(nplot(2),2));
    if length(nplot)==3
    t3=sprintf('Scores PC %g (%0.2f)',nplot(3),modelo.varexp(nplot(3),2));
    end
elseif size(modelo.T,2)~=size(modelo.Ttest,2)
    score_train = modelo.T(:,nplot);
    load_train  = modelo.P(:,nplot);
    t1=sprintf('Scores PC %g (%0.2f)',nplot(1),modelo.varexp(nplot(1),2));
    t2=sprintf('Scores PC %g (%0.2f)',nplot(2),modelo.varexp(nplot(2),2));
    if length(nplot)==3
    t3=sprintf('Scores PC %g (%0.2f)',nplot(3),modelo.varexp(nplot(3),2));
    end
end

if length(nplot)==2
% Gráfico bi-plot (2D) com identificação numérica das amostras
if size(modelo.T,2)==size(modelo.Ttest,2)  % +++ Gráfico dos scores com matriz de teste
    figure(1),plot(score_train(:,1),score_train(:,2),'k.','MarkerSize',6), hold on
    for ki=1:size(modelo.T,1)
        if isnumeric(nsamples), text(score_train(ki,1),score_train(ki,2),num2str(nsamples(ki)),'FontSize',12);
        else text(score_train(ki,1),score_train(ki,2),nsamples{ki},'FontSize',12);
        end
    end
    plot(score_test(:,1),score_test(:,2),'r.','MarkerSize',6), hold on
    for ki=1:size(modelo.Ttest,1)
        p1=text(score_test(ki,1),score_test(ki,2),strcat('t',num2str(ki)),'FontSize',12);
        set(p1,'Color','r');
    end
    xlabel(t1,'FontSize',14)
    ylabel(t2,'FontSize',14)
    % adição dos loadings
    for ki=1:size(modelo.P,1)
        px1=[0,max(max(score_train))*load_train(ki,1)];    px2=[0,max(max(score_train))*load_train(ki,2)]; 
        plot(px1,px2,'b','LineWidth',2), hold on
        if length(nvar)>1
            text(px1(2),px2(2),nvar{ki},'FontSize',12);
        else
            ptexto = strcat('X',num2str(ki));    text(px1(2),px2(2),ptexto,'FontSize',12);
        end
    end
    hline(0,'k:'),vline(0,'k:');
    % fim >> Gráfico dos scores sem matriz de teste
else  % +++ Gráfico dos scores sem matriz de teste
    figure(1),plot(score_train(:,1),score_train(:,2),'k.','MarkerSize',6),hold on
    for ki=1:size(modelo.T,1)
        if isnumeric(nsamples), text(score_train(ki,1),score_train(ki,2),num2str(nsamples(ki)),'FontSize',12);
        else text(score_train(ki,1),score_train(ki,2),nsamples{ki},'FontSize',12);
        end
    end
    xlabel(t1,'FontSize',14)
    ylabel(t2,'FontSize',14)
    % adição dos loadings
    for ki=1:size(modelo.P,1)
        px1=[0,max(max(score_train))*load_train(ki,1)];    px2=[0,max(max(score_train))*load_train(ki,2)]; 
        plot(px1,px2,'b','LineWidth',2), hold on
        if length(nvar)>1
            text(px1(2),px2(2),nvar{ki},'FontSize',12);
        else
            ptexto = strcat('X',num2str(ki));    text(px1(2),px2(2),ptexto,'FontSize',12);
        end
    end
    hline(0,'k:'),vline(0,'k:');hold off
    % fim >> Gráfico dos scores sem matriz de teste
end
% Caso as amostras em X possuam classes
% sub-rotina para fazer o gráfico dos scores
if length(modelo.classX)>1 || size(modelo.T,2)==size(modelo.Ttest,2) 
    if length(modelo.classX)>1 && size(modelo.T,2)==size(modelo.Ttest,2)
        Ttest=[score_train;score_test];
        classXt=(max(modelo.classX)+1)*ones(size(modelo.Ttest,1),1);
        classX2=[modelo.classX;classXt];
        grafico_score2(Ttest,classX2,modelo.varexp,load_train,nvar,nplot);  % Gráfico dos scores com amostras de teste.
    elseif length(modelo.classX)<=1 && size(modelo.T,2)==size(modelo.Ttest,2)
        classX2=[ones(size(score_train,1),1);2*ones(size(score_test,1),1)];
        Ttest=[score_train;score_test];
        grafico_score2(Ttest,classX2,modelo.varexp,load_train,nvar,nplot);
    else
        grafico_score2(score_train,modelo.classX,modelo.varexp,load_train,nvar,nplot);  % Gráfico dos scores sem amostras de teste.
    end
end


elseif length(nplot)==3  % Gráfico bi-plot (3D) com identificação numérica das amostras
if size(modelo.T,2)==size(modelo.Ttest,2)  % +++ Gráfico dos scores com matriz de teste
    figure(1),plot3(score_train(:,1),score_train(:,2),score_train(:,3),'k.','MarkerSize',6), hold on
    for ki=1:size(modelo.T,1)
        if isnumeric(nsamples), text(score_train(ki,1),score_train(ki,2),score_train(ki,3),num2str(nsamples(ki)),'FontSize',12);
        else text(score_train(ki,1),score_train(ki,2),score_train(ki,3),nsamples{ki},'FontSize',12);
        end
    end
    plot3(score_test(:,1),score_test(:,2),score_test(:,3),'r.','MarkerSize',6), hold on
    for ki=1:size(score_test,1)
        p1=text(score_test(ki,1),score_test(ki,2),score_test(ki,3),strcat('t',num2str(ki)),'FontSize',12);
        set(p1,'Color','r');
    end
    xlabel(t1,'FontSize',14)
    ylabel(t2,'FontSize',14)
    zlabel(t3,'FontSize',14)
    % adição dos loadings
    eixo_max = max(max(score_train));
    for ki=1:size(modelo.P,1)
        px1=[0,eixo_max*load_train(ki,1)];    
        px2=[0,eixo_max*load_train(ki,2)];
        px3=[0,eixo_max*load_train(ki,3)];
        plot3(px1,px2,px3,'b','LineWidth',2), hold on
        if length(nvar)>1
            text(px1(2),px2(2),px3(2),nvar{ki},'FontSize',12);
        else
            ptexto=strcat('X',num2str(ki));    text(px1(2),px2(2),px2(3),ptexto,'FontSize',12);
        end
    end
    hline(0,'k:'),vline(0,'k:'),zline(0,0,'k:');
    % fim >> Gráfico dos scores sem matriz de teste
else  % +++ Gráfico dos scores sem matriz de teste
    figure(1),plot3(score_train(:,1),score_train(:,2),score_train(:,3),'k.','MarkerSize',6),hold on
    for ki=1:size(modelo.T,1)
        if isnumeric(nsamples), text(score_train(ki,1),score_train(ki,2),score_train(ki,3),num2str(nsamples(ki)),'FontSize',12);
        else text(score_train(ki,1),score_train(ki,2),score_train(ki,3),nsamples{ki},'FontSize',12);
        end
    end
    xlabel(t1,'FontSize',14)
    ylabel(t2,'FontSize',14)
    zlabel(t3,'FontSize',14)
    % adição dos loadings
    eixo_max = max(max(score_train));
    for ki=1:size(modelo.P,1)
        px1=[0,eixo_max*load_train(ki,1)];    
        px2=[0,eixo_max*load_train(ki,2)];
        px3=[0,eixo_max*load_train(ki,3)];
        plot3(px1,px2,px3,'b','LineWidth',2), hold on
        if length(nvar)>1
            text(px1(2),px2(2),px3(2),nvar{ki},'FontSize',12);
        else
            ptexto=strcat('X',num2str(ki));    text(px1(2),px2(2),px1(3),ptexto,'FontSize',12);
        end
    end
    hline(0,'k:'),vline(0,'k:'),zline(0,0,'k:');hold off
    % fim >> Gráfico dos scores sem matriz de teste
end
% Caso as amostras em X possuam classes
% sub-rotina para fazer o gráfico dos scores
if length(modelo.classX)>1 || size(modelo.T,2)==size(modelo.Ttest,2) 
    if length(modelo.classX)>1 && size(modelo.T,2)==size(modelo.Ttest,2)
        Ttest=[score_train;score_test];
        classXt=(max(modelo.classX)+1)*ones(size(score_test,1),1);
        classX2=[modelo.classX;classXt];
        grafico_score3(Ttest,classX2,modelo.varexp,load_train,nvar,nplot,eixo_max);  % Gráfico dos scores com amostras de teste.
    elseif length(modelo.classX)<=1 && size(modelo.T,2)==size(modelo.Ttest,2)
        classX2=[ones(size(modelo.T,1),1);2*ones(size(modelo.Ttest,1),1)];
        Ttest=[score_train;score_test];
        grafico_score3(Ttest,classX2,modelo.varexp,load_train,nvar,nplot,eixo_max);
    else
        grafico_score3(score_train,modelo.classX,modelo.varexp,load_train,nvar,nplot,eixo_max);  % Gráfico dos scores sem amostras de teste.
    end
end

end  % fim geral


%% Sub-rotinas
% Sub-rotinas para gráfico 2D  : grafico_score2
% Sub-rotinas para gráfico 3D  : grafico_score3
function grafico_score2(T,classX,varexp,P,nvar,nplot)
classes=unique(classX);
%[a1,classes]=confusionmat(classX,classX);
figure(2)
if length(classes)==1
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1)); 
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    legend(d1)
elseif length(classes)==2
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1)); 
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    legend(d1,d2)
elseif length(classes)==3
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    legend(d1,d2,d3)
elseif length(classes)==4
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    plot(x1(:,1),x1(:,2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,1),x2(:,2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,1),x3(:,2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,1),x4(:,2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
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
    plot(x5(:,1),x5(:,2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
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
    plot(x6(:,1),x6(:,2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
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
    plot(x7(:,1),x7(:,2),'k*','LineWidth',1,'MarkerSize',8), hold on
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
    plot(x8(:,1),x8(:,2),'r+','LineWidth',1,'MarkerSize',8), hold on
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
    plot(x9(:,1),x9(:,2),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
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
    plot(x10(:,1),x10(:,2),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold on
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10)     
end
% adicionando os loadings
for ki=1:size(P,1)
    px1=[0,max(max(T))*P(ki,1)];    px2=[0,max(max(T))*P(ki,2)]; 
    plot(px1,px2,'b','LineWidth',2), hold on
    if length(nvar)>1
        text(px1(2),px2(2),nvar{ki},'FontSize',12);
    else
        ptexto = strcat('X',num2str(ki));    text(px1(2),px2(2),ptexto,'FontSize',12);
    end
end
hline(0,'k:'),vline(0,'k:');hold off
t1=sprintf('Scores PC %g (%0.2f)',nplot(1),varexp(nplot(1),2));   xlabel(t1,'FontSize',14)
t2=sprintf('Scores PC %g (%0.2f)',nplot(2),varexp(nplot(2),2));   ylabel(t2,'FontSize',14)


function grafico_score3(T,classX,varexp,P,nvar,nplot,eixo_max)
[a1,classes]=confusionmat(classX,classX);
figure(2)
if length(classes)==1
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1)); 
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    legend(d1)
elseif length(classes)==2
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1)); 
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    legend(d1,d2)
elseif length(classes)==3
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,1),x3(:,2),x3(:,3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    legend(d1,d2,d3)
elseif length(classes)==4
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,1),x3(:,2),x3(:,3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,1),x4(:,2),x4(:,3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    legend(d1,d2,d3,d4)
elseif length(classes)==5
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,1),x3(:,2),x3(:,3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,1),x4(:,2),x4(:,3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,1),x5(:,2),x5(:,3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    legend(d1,d2,d3,d4,d5)
elseif length(classes)==6
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));    
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,1),x3(:,2),x3(:,3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,1),x4(:,2),x4(:,3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,1),x5(:,2),x5(:,3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,1),x6(:,2),x6(:,3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    legend(d1,d2,d3,d4,d5,d6)    
elseif length(classes)==7
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));    
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));    
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,1),x3(:,2),x3(:,3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,1),x4(:,2),x4(:,3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,1),x5(:,2),x5(:,3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,1),x6(:,2),x6(:,3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,1),x7(:,2),x7(:,3),'k*','LineWidth',1,'MarkerSize',8), hold on
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
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,1),x3(:,2),x3(:,3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,1),x4(:,2),x4(:,3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,1),x5(:,2),x5(:,3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,1),x6(:,2),x6(:,3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,1),x7(:,2),x7(:,3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,1),x8(:,2),x8(:,3),'r+','LineWidth',1,'MarkerSize',8), hold on
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
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,1),x3(:,2),x3(:,3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,1),x4(:,2),x4(:,3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,1),x5(:,2),x5(:,3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,1),x6(:,2),x6(:,3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,1),x7(:,2),x7(:,3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,1),x8(:,2),x8(:,3),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot3(x9(:,1),x9(:,2),x9(:,3),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
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
    plot3(x1(:,1),x1(:,2),x1(:,3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,1),x2(:,2),x2(:,3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,1),x3(:,2),x3(:,3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,1),x4(:,2),x4(:,3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,1),x5(:,2),x5(:,3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,1),x6(:,2),x6(:,3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,1),x7(:,2),x7(:,3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,1),x8(:,2),x8(:,3),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot3(x9(:,1),x9(:,2),x9(:,3),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    plot3(x10(:,1),x10(:,2),x10(:,3),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold on
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10)     
end
% adicionando os loadings
for ki=1:size(P,1)
    px1=[0,eixo_max*P(ki,1)];    
    px2=[0,eixo_max*P(ki,2)];
    px3=[0,eixo_max*P(ki,3)];
    plot3(px1,px2,px3,'b','LineWidth',2), hold on
    if length(nvar)>1
        text(px1(2),px2(2),px3(2),nvar{ki},'FontSize',12);
    else
        ptexto = strcat('X',num2str(ki));    text(px1(2),px2(2),px3(2),ptexto,'FontSize',12);
    end
end
hline(0,'k:'),vline(0,'k:'), zline(0,0,'k:'); hold off
t1=sprintf('Scores PC %g (%0.2f)',nplot(1),varexp(nplot(1),2));   xlabel(t1,'FontSize',14)
t2=sprintf('Scores PC %g (%0.2f)',nplot(2),varexp(nplot(2),2));   ylabel(t2,'FontSize',14)
t3=sprintf('Scores PC %g (%0.2f)',nplot(3),varexp(nplot(3),2));   zlabel(t3,'FontSize',14)

