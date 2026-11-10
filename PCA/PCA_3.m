
% Limpar tudo por precaução
clear all; clc;
delete(gcp('nocreate'));
computerName = getenv('COMPUTERNAME');

if strcmp(computerName, 'DESKTOP-0FPF1IU')
    Dados.cdPasta  = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\20250502 - Filtro';
    Dados.cdSalvar = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\20250502 - Filtro';
    Dados.cdFus = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções';
    Dados.cdLib = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções\libPLS_1.95';
    Dados.cdAir = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções\pls_chemometrics';
    Dados.cdExt = 'C:\Users\ellisson.paulo\Desktop\MIR\Extraido';
    Dados.cdMPA = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções\MPA';
    Dados.cdPCA = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções\PCA';
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
load('Out_G.mat', 'Out_G2')
X(Out_G2,:) = [];
Y = Y2; Y(Out_G2,:) = [];

cd(Dados.cdPCA);
num    = 1:1:size(X,2);
classX = repmat(1:4, 1, ceil(size(X,2)/4));
classX = classX(1:size(X,2)); % corta o excesso, se houver
modelo_none = pcamodel(X,{'none'},6,classX,num);

close all
options.alpha  = 0.1;
options.graf   = 1;
options.center = 100;
options.type   = "Ultra";
parpool(6);
[Elip_none,Sample_none] = Elipsoide2(modelo_none,options); % 7,55 min
delete(gcp('nocreate'));
% Elip_Plot(modelo_none,Elip_none,X)

cd(Dados.cdPasta)
save('Elip_3a','modelo_none','Elip_none','Sample_none');

cd(Dados.cdLib);
[X2,~] = Pretratamento(X,X,11);
plot(num,X2);
cd(Dados.cdPCA);
parpool(6);
modelo_deriv = pcamodel(X2,{'none'},3,classX,num);

close all
[Elip_deriv,Sample_deriv] = Elipsoide2(modelo_deriv,options); %9,4 Min
delete(gcp('nocreate'));
% Elip_Plot(modelo_deriv,Elip_deriv,X2)

cd(Dados.cdPasta)
save('Elip_3a','modelo_none','Elip_none','Sample_none',...
    'modelo_deriv','Elip_deriv','Sample_deriv');

%%

% Limpar tudo por precaução
clear all; clc;
computerName = getenv('COMPUTERNAME');

if strcmp(computerName, 'DESKTOP-0FPF1IU')
    Dados.cdPasta  = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\20250502 - Filtro';
    Dados.cdSalvar = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\20250502 - Filtro';
    Dados.cdFus = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções';
    Dados.cdLib = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções\libPLS_1.95';
    Dados.cdAir = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções\pls_chemometrics';
    Dados.cdExt = 'C:\Users\ellisson.paulo\Desktop\MIR\Extraido';
    Dados.cdMPA = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções\MPA';
    Dados.cdPCA = 'C:\Users\ellisson.paulo\LHTN Dropbox\Pesquisa Tommasi\Quimiometria\Funções\PCA';
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
load('Out_G.mat', 'Out_G2')
load('Elip_3a.mat', 'Elip_deriv', 'Elip_none', 'modelo_deriv', 'modelo_none')
Y           = Y2;
X2          = X;
X_Out       = X(Out_G2,:);
Y_Out       = Y(Out_G2,:);
X(Out_G2,:) = [];
Y(Out_G2,:) = [];

num = 1:1:1798;

close all
subplot(3,1,1);
plot(num,X2);
subplot(3,1,2);
plot(num,X_Out);
subplot(3,1,3);
plot(num,X);

close all
figure('Units','normalized','OuterPosition',[0 0 1 1]);

plot(1:1:1798, mean(X), 'b');
hold on
plot(1:1:1798, mean(X_Out), 'r');
plot(1:1:1798, mean(X2), 'k');
xlim([-17 1815]);                  
ylim([-0.0591 0.6615]);
legend('Rem','Out','All');

close all
cd(Dados.cdPCA);
Elip_Plot(modelo_none,Elip_none,X_Out);

close all
cd(Dados.cdLib);
[~,X_Out2] = Pretratamento(X,X_Out,11);
cd(Dados.cdPCA);
Elip_Plot(modelo_deriv,Elip_deriv,X_Out2);

%%

cd(Dados.cdPasta)
load('Sem média.mat')
load('Out_G.mat', 'Out_G2')
X(Out_G2,:)   = [];
ID_all = unique(IDs); 
IDs(Out_G2,:) = [];
ID_rem = unique(IDs); % 173 Amostras removidas.1

