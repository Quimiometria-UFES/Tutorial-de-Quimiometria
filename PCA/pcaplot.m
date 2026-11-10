function pcaplot(modelo,PC1,PC2,PC3,options);
% Funcao utilizada para desenvolver graficos importantes para a comparar PCA.

% input
% modelo :         % Modelo desenvolvido a pcamodel.
% modelo.xaxis     % Dimensao do eixo-x. Por exemplo, numero de onda.
% modelo.T;        % Scores de cada PCA por amostra.
% modelo.P;        %
% modelo.varexp;   %
% modelo.classX;   % Vetor de classes referente as amostras da matriz X.
% modelo.nsamples; % Nome das amostras (opcional)
% PC1:             % Primeira componente principal.
% PC2:             % Segunda componente principal.
% PC3:             % Terceira componente principal. Caso queira um grafico 3D.
% options;
% options.Score = (0) Sem grafico Score, (1) Com grafico Score, (2) Com
% grafico Score biplot
% options.Pareto = (0) Sem grafico Pareto, (1) Com grafico Pareto
% options.Loading = (0) Sem grafico Loading, (1) Com grafico Loading
% options.Test = (0) Scores SEM test, (1) Scores COM test
% options.spname =  Vetor com nome das variaveis.

% EXEMPLOS
% options.Score = 1;
% options.Pareto = 1;
% options.Loading = 1;
% pcaplot(modelo,1,2,options);
%
% pcaplot(modelo,1,3,options);
% pcaplot(modelo,1,2,3,options);
% pcaplot(modelo,1,2);

% Programar melhor a localizacao do spname, usar o vetor 0,0 como
% referencia.

%% Determinando certas propriedades necessarias.

T = modelo.T;
classX = modelo.classX;
varexp = modelo.varexp;
xaxis = modelo.xaxis;
npc = modelo.npc;
P = modelo.P;

if nargin == 4;
    options=PC3;
    PC3 = [];
    AAA = 0;
else
    AAA = 1;
end

if isfield(options,'Test')
    error('Isso não foi programado ainda, desculpe.');
else
    options.Test = 0;
end


if nargin == 3;
    options.Score = 1;
    options.Pareto = 1;
    options.Loading = 1;
end

try
    spname = options.spname;
catch
    spname = 1:1:size(P,1);  %iscell(spname)
    mat2str(spname);
end


%% Score

if options.Score > 0;
    
    if isempty(PC3)
        % Grafico 2D
        
        figure(1);
        if options.Score ==1;
            grafico_score(T,classX,varexp,PC1,PC2);hold on;  % Grï¿½fico dos scores sem amostras de teste.
            if options.Test ==1;
                %plot(modelo.Ttest(:,PC1),modelo.Ttest(:,PC2),'r.','MarkerSize',6); hold on % Grï¿½fico dos scores sem amostras de teste.
                scatter(modelo.Ttest(:,PC1),modelo.Ttest(:,PC2),100,'filled','MarkerFaceAlpha',0.6,'MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[[0.9100 0.4100 0.1700]]);
                A = size(unique(classX),1)+1;
                Legend = legend;
                Legend.String(A) = {sprintf('Test')};
            end
        elseif options.Score == 2;
            if size(P,1) > 15;
                tab = sprintf('Nao e recomendado fazer biplot quando tem mais de 15 variaveis');
                disp(tab);
            end
            graf_S_L(T,P,classX,varexp,spname,PC1,PC2); hold on;
            if options.Test ==1;
                %plot(modelo.Ttest(:,PC1),modelo.Ttest(:,PC2),'r.','MarkerSize',6); hold on % Grï¿½fico dos scores sem amostras de teste.
                scatter(modelo.Ttest(:,PC1),modelo.Ttest(:,PC2),100,'filled','MarkerFaceAlpha',0.6,'MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[[0.9100 0.4100 0.1700]]);
                A = size(unique(classX),1)+1;
                Legend = legend;
                Legend.String(A) = {sprintf('Test')};
            end
        end
        
    else
        % Grï¿½fico 3D
        figure(1);
        if options.Score ==1;
            grafico_score3D(T,classX,varexp,PC1,PC2,PC3);hold on;  % Grï¿½fico dos scores sem amostras de teste.
            if options.Test ==1;
                %plot(modelo.Ttest(:,PC1),modelo.Ttest(:,PC2),'r.','MarkerSize',6); hold on % Grï¿½fico dos scores sem amostras de teste.
                scatter3(modelo.Ttest(:,PC1),modelo.Ttest(:,PC2),modelo.Ttest(:,PC3),100,'filled','MarkerFaceAlpha',0.6,'MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[[0.9100 0.4100 0.1700]]);
                A = size(unique(classX),1)+1;
                Legend = legend;
                Legend.String(A) = {sprintf('Test')};
            end
        elseif options.Score == 2;
            if size(P,1) > 15;
                tab = sprintf('Nao e recomendado fazer biplot quando tem mais de 15 variaveis');
                disp(tab);
            end
            graf_S_L_3d(T,P,classX,varexp,spname,PC1,PC2,PC3);hold on;
            if options.Test ==1;
                %plot(modelo.Ttest(:,PC1),modelo.Ttest(:,PC2),'r.','MarkerSize',6); hold on % Grï¿½fico dos scores sem amostras de teste.
                scatter3(modelo.Ttest(:,PC1),modelo.Ttest(:,PC2),modelo.Ttest(:,PC3),100,'filled','MarkerFaceAlpha',0.6,'MarkerFaceColor',[0.8500 0.3250 0.0980],'MarkerEdgeColor',[[0.9100 0.4100 0.1700]]);
                A = size(unique(classX),1)+1;
                Legend = legend;
                Legend.String(A) = {sprintf('Test')};
            end
            
        end
    end
    
end
%% Loading

if options.Loading > 0
    
    figure(2) % Grafico dos loadings
    X2 = mean(modelo.X);
    P = modelo.P(:,1:1:size(modelo.P,2))';
    Pmin = min(min(P)); Pmax= max(max(P));
    X2 = (X2-min(X2))/(max(X2)-min(X2));
    X2 = X2*(Pmax/max(X2));
    X2 = X2+Pmax*1.1;
    plot(xaxis,X2,'k','LineWidth',1); hold on;
    ylabel('Variable','FontSize',14);
    if AAA==0
        plot(xaxis, modelo.P(:,PC1), 'b', 'LineWidth', 2), hold on;
        plot(xaxis, modelo.P(:,PC2), 'r', 'LineWidth', 2), hold off;
        p1 = sprintf('Load PC %0.2f (%0.2f)', PC1, modelo.varexp(1,2));
        p2 = sprintf('Load PC %0.2f (%0.2f)', PC2, modelo.varexp(2,2));
        legend(p1, p2);
    elseif AAA==1
        plot(xaxis,modelo.P(:,PC1),'b'), hold on;
        plot(xaxis,modelo.P(:,PC2),'r'), hold on;
        plot(xaxis,modelo.P(:,PC3),'k'), hold off;
        p1=sprintf('Load PC %0.2f (%0.2f)', PC1, modelo.varexp(1,2));
        p2=sprintf('Load PC %0.2f (%0.2f)', PC2, modelo.varexp(2,2));
        p3=sprintf('Load PC %0.2f (%0.2f)', PC3,modelo.varexp(3,2));
        legend(p1,p2,p3);
    else
        error('Não foi programado para isso.');
    end
    
    hline(0,'k:');
    xlabel('Variables','FontSize',14)
    ylabel('Loadings','FontSize',14)
    
    % Legenda
    if AAA==0
        try
            legend("Espectro",p1,p2,"Location","northeastoutside");
        catch
            error('Verique a sua versÃ£o de Matlab, caso seja mais antiga que Matlab2018b, modifique as funcoes removendo as " e colocando uma simples no lugar.');
        end
    elseif AAA==1
        legend("Espectro",p1,p2,p3,"Location","northeastoutside");
    end
    
end

%% Pareto

if options.Pareto > 0;
    figure(3)
    bar(modelo.varexp(1:npc,2),0.8), hold on
    plot(1:npc,modelo.varexp(1:npc,3),'k.'), hold on
    plot(1:npc,modelo.varexp(1:npc,3),'k'), hold off
    xlabel('Componente Principal','FontSize',14)
    ylabel('Variancia Explicada (%)','FontSize',14)
    
end

end

% Grafico Score
function grafico_score(T,classX,varexp,PC1,PC2);
% sub-rotina para fazer o grï¿½fico dos scores
[a1,classes]=confusionmat(classX,classX);

if length(classes)==1
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
elseif length(classes)==2
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold off
elseif length(classes)==3
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold off
elseif length(classes)==4
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold off
elseif length(classes)==5
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold off
elseif length(classes)==6
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold off
elseif length(classes)==7
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,PC1),x7(:,PC2),'k*','LineWidth',1,'MarkerSize',8), hold off
elseif length(classes)==8
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,PC1),x7(:,PC2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,PC1),x8(:,PC2),'r+','LineWidth',1,'MarkerSize',8), hold off
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
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,PC1),x7(:,PC2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,PC1),x8(:,PC2),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot(x9(:,PC1),x9(:,PC2),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold off
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
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,PC1),x7(:,PC2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,PC1),x8(:,PC2),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot(x9(:,PC1),x9(:,PC2),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    plot(x10(:,PC1),x10(:,PC2),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold off
end

hline(0,'k:');
vline(0,'k:');
hline(0,'k:');
msg = 'Scores PC XXX (%0.2f)';
msgT1 = strrep(msg,'XXX',num2str(PC1));
msgT2 = strrep(msg,'XXX',num2str(PC2));
t1=sprintf(msgT1,varexp(PC1,2));  xlabel(t1,'FontSize',14);
t2=sprintf(msgT2,varexp(PC2,2));  ylabel(t2,'FontSize',14);

if length(classes)==1 % Legenda
    legend(d1,"Location","northeastoutside");
elseif length(classes)==2
    legend(d1,d2,"Location","northeastoutside");
elseif length(classes)==3
    legend(d1,d2,d3,"Location","northeastoutside");
elseif length(classes)==4
    legend(d1,d2,d3,d4,"Location","northeastoutside");
elseif length(classes)==5
    legend(d1,d2,d3,d4,d5,"Location","northeastoutside");
elseif length(classes)==6
    legend(d1,d2,d3,d4,d5,d6,"Location","northeastoutside");
elseif length(classes)==7
    legend(d1,d2,d3,d4,d5,d6,d7,"Location","northeastoutside");
elseif length(classes)==8
    legend(d1,d2,d3,d4,d5,d6,d7,d8,"Location","northeastoutside");
elseif length(classes)==9
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,"Location","northeastoutside");
elseif length(classes)==10
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,"Location","northeastoutside");
end

end

% Grafico Score 3D
function grafico_score3D(T,classX,varexp,PC1,PC2,PC3);
% sub-rotina para fazer o grï¿½fico dos scores
[a1,classes]=confusionmat(classX,classX);

if size(classes,1)==1
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    legend(d1)
elseif size(classes,1)==2
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]),, hold off
    legend(d1,d2)
elseif size(classes,1)==3
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold off
    legend(d1,d2,d3,'x')
elseif size(classes,1)==4
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold off
    legend(d1,d2,d3,d4)
elseif size(classes,1)==5
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]),, hold off
    legend(d1,d2,d3,d4,d5)
elseif size(classes,1)==6
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold off
    legend(d1,d2,d3,d4,d5,d6)
elseif size(classes,1)==7
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold off
    legend(d1,d2,d3,d4,d5,d6,d7)
elseif size(classes,1)==8
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,PC1),x8(:,PC2),x8(:,PC3),'r+','LineWidth',1,'MarkerSize',8), hold off
    legend(d1,d2,d3,d4,d5,d6,d7,d8)
elseif size(classes,1)==9
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));
    c9=find(classX==classes(9));   x9=T(c9,:);   d9=sprintf('Classe %g',classes(9));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,PC1),x8(:,PC2),x8(:,PC3),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot3(x9(:,PC1),x9(:,PC2),x9(:,PC3),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold off
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9)
elseif size(classes,1)==10
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
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,PC1),x8(:,PC2),x8(:,PC3),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot3(x9(:,PC1),x9(:,PC2),x9(:,PC3),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    plot3(x10(:,PC1),x10(:,PC2),x10(:,PC3),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold off
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10)
elseif size(classes,1)==11
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
    c11=find(classX==classes(11)); x11=T(c11,:); d11=sprintf('Classe %g',classes(11));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,PC1),x8(:,PC2),x8(:,PC3),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot3(x9(:,PC1),x9(:,PC2),x9(:,PC3),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    plot3(x10(:,PC1),x10(:,PC2),x10(:,PC3),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold on
    plot3(x11(:,PC1),x11(:,PC2),x11(:,PC3),'bo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold off
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11)
    elseif size(classes,1)==12
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
    c11=find(classX==classes(11)); x11=T(c11,:); d11=sprintf('Classe %g',classes(11));
    c12=find(classX==classes(12)); x12=T(c12,:); d12=sprintf('Classe %g',classes(12));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,PC1),x8(:,PC2),x8(:,PC3),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot3(x9(:,PC1),x9(:,PC2),x9(:,PC3),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    plot3(x10(:,PC1),x10(:,PC2),x10(:,PC3),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold on
    plot3(x11(:,PC1),x11(:,PC2),x11(:,PC3),'bo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold on
    plot3(x12(:,PC1),x12(:,PC2),x12(:,PC3),'r+','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold off
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,d11,d12)
else
    error("Nao foi programado para mais de 11 classes.");
end

grid on
msg = 'Scores PC XXX (%0.2f)';
msgT1 = strrep(msg,'XXX',num2str(PC1));
msgT2 = strrep(msg,'XXX',num2str(PC2));
msgT3 = strrep(msg,'XXX',num2str(PC3));
t1=sprintf(msgT1,varexp(PC1,2));  xlabel(t1,'FontSize',14);
t2=sprintf(msgT2,varexp(PC2,2));  ylabel(t2,'FontSize',14);
t3=sprintf(msgT3,varexp(PC3,2));  zlabel(t3,'FontSize',14);

if length(classes)==1 % Legenda
    legend(d1,"Location","northeastoutside");
elseif length(classes)==2
    legend(d1,d2,"Location","northeastoutside");
elseif length(classes)==3
    legend(d1,d2,d3,"Location","northeastoutside");
elseif length(classes)==4
    legend(d1,d2,d3,d4,"Location","northeastoutside");
elseif length(classes)==5
    legend(d1,d2,d3,d4,d5,"Location","northeastoutside");
elseif length(classes)==6
    legend(d1,d2,d3,d4,d5,d6,"Location","northeastoutside");
elseif length(classes)==7
    legend(d1,d2,d3,d4,d5,d6,d7,"Location","northeastoutside");
elseif length(classes)==8
    legend(d1,d2,d3,d4,d5,d6,d7,d8,"Location","northeastoutside");
elseif length(classes)==9
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,"Location","northeastoutside");
elseif length(classes)==10
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,"Location","northeastoutside");
end

end

% Grafico Score biplot
function graf_S_L(T,P,classX,varexp,spname,PC1,PC2);
% sub-rotina para fazer o grï¿½fico dos scores
P2 = P(:,[PC1 PC2]);
T2 = T(:,[PC1 PC2]);
nvar = spname;

%% Parte dos Scores

[a1,classes]=confusionmat(classX,classX);

if length(classes)==1
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
elseif length(classes)==2
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
elseif length(classes)==3
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
elseif length(classes)==4
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
elseif length(classes)==5
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
elseif length(classes)==6
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
elseif length(classes)==7
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,PC1),x7(:,PC2),'k*','LineWidth',1,'MarkerSize',8), hold on
elseif length(classes)==8
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,PC1),x7(:,PC2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,PC1),x8(:,PC2),'r+','LineWidth',1,'MarkerSize',8), hold on
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
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,PC1),x7(:,PC2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,PC1),x8(:,PC2),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot(x9(:,PC1),x9(:,PC2),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
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
    plot(x1(:,PC1),x1(:,PC2),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot(x2(:,PC1),x2(:,PC2),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot(x3(:,PC1),x3(:,PC2),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot(x4(:,PC1),x4(:,PC2),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot(x5(:,PC1),x5(:,PC2),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot(x6(:,PC1),x6(:,PC2),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot(x7(:,PC1),x7(:,PC2),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot(x8(:,PC1),x8(:,PC2),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot(x9(:,PC1),x9(:,PC2),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    plot(x10(:,PC1),x10(:,PC2),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold on
end

%% Parte dos Loadings
for ki=1:size(P,1); %ki=3
    px1=[0,max(max(T2))*P2(ki,1)];    px2=[0,max(max(T2))*P2(ki,2)];
    plot(px1,px2,'b','LineWidth',2), hold on
end
for ki=1:size(P,1);
    px1=[0,max(max(T2))*P2(ki,1)];    px2=[0,max(max(T2))*P2(ki,2)];
    if iscell(spname)==1
        text(px1(2),px2(2),nvar{ki},'FontSize',12);
    elseif iscell(spname)==0;
        text(px1(2),px2(2),num2str(ki),'FontSize',12);
    else
        ptexto = strcat('X',num2str(ki));    text(px1(2),px2(2),ptexto,'FontSize',12);
    end
end

%% Outras informaï¿½ï¿½es

hline(0,'k:');vline(0,'k:');
hline(0,'k:');vline(0,'k:'); %Sim, duas vezes.
msg = 'Scores PC XXX (%0.2f)';
msgT1 = strrep(msg,'XXX',num2str(PC1));
msgT2 = strrep(msg,'XXX',num2str(PC2));
t1=sprintf(msgT1,varexp(PC1,2));  xlabel(t1,'FontSize',14);
t2=sprintf(msgT2,varexp(PC2,2));  ylabel(t2,'FontSize',14);

if length(classes)==1 % Legenda
    legend(d1,"Location","northeastoutside");
elseif length(classes)==2
    legend(d1,d2,"Location","northeastoutside");
elseif length(classes)==3
    legend(d1,d2,d3,"Location","northeastoutside");
elseif length(classes)==4
    legend(d1,d2,d3,d4,"Location","northeastoutside");
elseif length(classes)==5
    legend(d1,d2,d3,d4,d5,"Location","northeastoutside");
elseif length(classes)==6
    legend(d1,d2,d3,d4,d5,d6,"Location","northeastoutside");
elseif length(classes)==7
    legend(d1,d2,d3,d4,d5,d6,d7,"Location","northeastoutside");
elseif length(classes)==8
    legend(d1,d2,d3,d4,d5,d6,d7,d8,"Location","northeastoutside");
elseif length(classes)==9
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,"Location","northeastoutside");
elseif length(classes)==10
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,"Location","northeastoutside");
end

end

% Grafico Score biplot 3d
function graf_S_L_3d(T,P,classX,varexp,spname,PC1,PC2,PC3);
% sub-rotina para fazer o grï¿½fico dos scores
P2 = P(:,[PC1 PC2 PC3]);
T2 = T(:,[PC1 PC2 PC3]);
nvar = spname;

%% Parte dos Scores

[a1,classes]=confusionmat(classX,classX);

if size(classes,1)==1
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    legend(d1)
elseif size(classes,1)==2
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]),, hold on
    legend(d1,d2)
elseif size(classes,1)==3
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    legend(d1,d2,d3,'x')
elseif size(classes,1)==4
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    legend(d1,d2,d3,d4)
elseif size(classes,1)==5
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]),, hold on
    legend(d1,d2,d3,d4,d5)
elseif size(classes,1)==6
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    legend(d1,d2,d3,d4,d5,d6)
elseif size(classes,1)==7
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    legend(d1,d2,d3,d4,d5,d6,d7)
elseif size(classes,1)==8
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,PC1),x8(:,PC2),x8(:,PC3),'r+','LineWidth',1,'MarkerSize',8), hold on
    legend(d1,d2,d3,d4,d5,d6,d7,d8)
elseif size(classes,1)==9
    c1=find(classX==classes(1));   x1=T(c1,:);   d1=sprintf('Classe %g',classes(1));
    c2=find(classX==classes(2));   x2=T(c2,:);   d2=sprintf('Classe %g',classes(2));
    c3=find(classX==classes(3));   x3=T(c3,:);   d3=sprintf('Classe %g',classes(3));
    c4=find(classX==classes(4));   x4=T(c4,:);   d4=sprintf('Classe %g',classes(4));
    c5=find(classX==classes(5));   x5=T(c5,:);   d5=sprintf('Classe %g',classes(5));
    c6=find(classX==classes(6));   x6=T(c6,:);   d6=sprintf('Classe %g',classes(6));
    c7=find(classX==classes(7));   x7=T(c7,:);   d7=sprintf('Classe %g',classes(7));
    c8=find(classX==classes(8));   x8=T(c8,:);   d8=sprintf('Classe %g',classes(8));
    c9=find(classX==classes(9));   x9=T(c9,:);   d9=sprintf('Classe %g',classes(9));
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,PC1),x8(:,PC2),x8(:,PC3),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot3(x9(:,PC1),x9(:,PC2),x9(:,PC3),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9)
elseif size(classes,1)==10
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
    plot3(x1(:,PC1),x1(:,PC2),x1(:,PC3),'ko','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[.8,.8,.8]), hold on
    plot3(x2(:,PC1),x2(:,PC2),x2(:,PC3),'r^','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,153/255]), hold on
    plot3(x3(:,PC1),x3(:,PC2),x3(:,PC3),'bd','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[153/255,153/255,1]), hold on
    plot3(x4(:,PC1),x4(:,PC2),x4(:,PC3),'gs','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,153/255]), hold on
    plot3(x5(:,PC1),x5(:,PC2),x5(:,PC3),'mp','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[1,153/255,1]), hold on
    plot3(x6(:,PC1),x6(:,PC2),x6(:,PC3),'c>','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[153/255,1,1]), hold on
    plot3(x7(:,PC1),x7(:,PC2),x7(:,PC3),'k*','LineWidth',1,'MarkerSize',8), hold on
    plot3(x8(:,PC1),x8(:,PC2),x8(:,PC3),'r+','LineWidth',1,'MarkerSize',8), hold on
    plot3(x9(:,PC1),x9(:,PC2),x9(:,PC3),'gv','LineWidth',1,'MarkerSize',6,'MarkerFaceColor',[0,204/255,204/255]), hold on
    plot3(x10(:,PC1),x10(:,PC2),x10(:,PC3),'mo','LineWidth',1,'MarkerSize',8,'MarkerFaceColor',[204/255,204/255,1]), hold on
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10)
else
    error("Nao foi programado para mais de 10 classes.");
end

%% Parte dos Loadings
for ki=1:size(P,1); %ki=3
    
    px1=[0,max(max(T2))*P2(ki,1)];
    px2=[0,max(max(T2))*P2(ki,2)];
    px3=[0,max(max(T2))*P2(ki,3)];
    
    plot3(px1,px2,px3,'b','LineWidth',2); hold on
    
end
for ki=1:size(P,1);
    px1=[0,max(max(T2))*P2(ki,1)];
    px2=[0,max(max(T2))*P2(ki,2)];
    px3=[0,max(max(T2))*P2(ki,3)];
    if iscell(spname)==1
        text(px1(2),px2(2),px3(2),nvar{ki},'FontSize',12);
    elseif iscell(spname)==0;
        text(px1(2),px2(2),px3(2),num2str(ki),'FontSize',12);
    else
        ptexto = strcat('X',num2str(ki));
        text(px1(2),px2(2),px3(2),ptexto,'FontSize',12);
    end
end

%% Outras informaï¿½ï¿½es

grid on
msg = 'Scores PC XXX (%0.2f)';
msgT1 = strrep(msg,'XXX',num2str(PC1));
msgT2 = strrep(msg,'XXX',num2str(PC2));
msgT3 = strrep(msg,'XXX',num2str(PC3));
t1=sprintf(msgT1,varexp(PC1,2));  xlabel(t1,'FontSize',14);
t2=sprintf(msgT2,varexp(PC2,2));  ylabel(t2,'FontSize',14);
t3=sprintf(msgT3,varexp(PC3,2));  zlabel(t3,'FontSize',14);

if length(classes)==1 % Legenda
    legend(d1,"Location","northeastoutside");
elseif length(classes)==2
    legend(d1,d2,"Location","northeastoutside");
elseif length(classes)==3
    legend(d1,d2,d3,"Location","northeastoutside");
elseif length(classes)==4
    legend(d1,d2,d3,d4,"Location","northeastoutside");
elseif length(classes)==5
    legend(d1,d2,d3,d4,d5,"Location","northeastoutside");
elseif length(classes)==6
    legend(d1,d2,d3,d4,d5,d6,"Location","northeastoutside");
elseif length(classes)==7
    legend(d1,d2,d3,d4,d5,d6,d7,"Location","northeastoutside");
elseif length(classes)==8
    legend(d1,d2,d3,d4,d5,d6,d7,d8,"Location","northeastoutside");
elseif length(classes)==9
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,"Location","northeastoutside");
elseif length(classes)==10
    legend(d1,d2,d3,d4,d5,d6,d7,d8,d9,d10,"Location","northeastoutside");
end

end

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

end

function h = vline(x,lc)
[m,n] = size(x);
if m>1 && n>1
    error('Error - input must be a scaler or vector')
elseif n>1
    x   = x';
    m   = n;
end

v = axis;
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

end


