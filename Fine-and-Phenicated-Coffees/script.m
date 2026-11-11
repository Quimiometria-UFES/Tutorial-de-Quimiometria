

% Loading the required packages (io and statistics)
pkg load io
pkg load statistics

%Loading Mid-Infrared Spectra – FTIR Data
cd('C:\...')
MIR = xlsread('MIR.xlsx', 'FTIR', 'A1:BQD210'); 

%Wavenumber Axis Generation
num = linspace(3999.43349933624,650.420452594757,1798);

%Plotting Raw Spectra
plot(num,MIR);
xlabel('Wavenumber (cm^-^1)', 'fontsize', 16)
ylabel('Absorbance', 'fontsize', 16)
set(gca, 'xdir', 'reverse')
axis tight

%Generation of the Class Label Vector (y)
y = [1*ones(90,1);2*ones(120,1)];
% 1 - Arabica coffee samples: APM, HARD, and FINE CUP - Fine coffees
% 2 - Arabica coffee samples: RIOZONA - Phenicated coffees

%Data Preprocessing - PRETRAT
cd('C:\...')
trat = {'msc'};
Xp = pretrat(MIR,[],trat);

%Plotting the Preprocessed Spectra
plot(num, Xp)
xlabel('Wavenumber (cm^-^1)', 'fontsize', 16)
ylabel('Absorbance', 'fontsize', 16)
set(gca, 'xdir', 'reverse')
axis tight

%Plotting the Raw Spectra and Preprocessed Spectra
subplot(2,1,1), plot(num,MIR)
xlabel('Wavenumber (cm^-^1)', 'fontsize', 16)
ylabel('Absorbance', 'fontsize', 16)
set(gca, 'xdir', 'reverse')
axis tight
subplot(2,1,2), plot(num,Xp)
xlabel('Wavenumber (cm^-^1)', 'fontsize', 16)
ylabel('Absorbance', 'fontsize', 16)
set(gca, 'xdir', 'reverse')
axis tight

%Plotting the Mean Spectrum
plot(num, mean(MIR(1:90,:)), 'b'), hold on %Using the Mean Spectrum of Fine Cup Coffee Samples
xlabel('Wavenumber (cm^-^1)', 'fontsize', 16)
ylabel('Absorbance', 'fontsize', 16)
set(gca, 'xdir', 'reverse')
axis tight
plot(num, mean(MIR(91:210,:)), 'r')
xlabel('Wavenumber (cm^-^1)', 'fontsize', 16)
ylabel('Absorbance', 'fontsize', 16)
set(gca, 'xdir', 'reverse')
ylim([-0.02 0.25])  
%axis tight
%title('Perfil espectral médio', 'fontsize', 16)
legend('Mean Fine','Mean Fenicate', 'fontsize', 14, 'location', 'northwest'), hold off

%######################## PCA ########################%
%Using PCAMODEL
cd('C:\...')
modelo = pcamodel(Xp,{'center'}, [], 5, y)

%Loadings PC1 x PC2
subplot (2,1,1), plot(num, modelo.P(:,1)), hold on %PC1
title('Loadings PC1', 'fontsize', 18)
ylabel('Loadings', 'fontsize', 16)
xlabel('Wavenumber (cm^-^1)', 'fontsize', 16)
set(gca, 'xdir', 'reverse')
subplot (2,1,2), plot(num, modelo.P(:,2)), hold off %PC2
title('Loadings PC2', 'fontsize', 18)
ylabel('Loadings', 'fontsize', 16)
xlabel('Wavenumber (cm^-^1)', 'fontsize', 16)
set(gca, 'xdir', 'reverse')

%#################################### PLS_DA ####################################%

%Replicate Vector Generation
cd('C:\...')
rep = replicar(3,70)

% Locating the LIBPLS Folder – Splitting the Data into Training and Test Sets
[objetos,Xtrain,Xtest,ytrain,ytest]=caltestda(MIR,y,70,'k',rep,{'center'});

%Data Preprocessing - PRETRAT
[Xtrainp,Xtestp]=pretrat(Xtrain,Xtest,trat);
% Defining the desired spectral range
intervalo_min = 650;    % Minimum wavenumber
intervalo_max = 1500;   % Maximum wavenumber

% Identifying the indices in the wavenumber axis ('num') within the specified range
indices = (num >= intervalo_min) & (num <= intervalo_max);

% Plotting the test set spectra within the selected spectral range
plot(num(indices),Xtestp(:, indices))
xlabel('Wavenumber (cm^{-1})','fontsize',14);
ylabel('Absorbance','fontsize',14);
axis tight
set(gca,'XDir','reverse')

% Plotting the training set spectra within the selected spectral range
plot(num(indices),Xtrainp(:, indices))
xlabel('Wavenumber (cm^{-1})','fontsize',14);
ylabel('Absorbance','fontsize',14);
axis tight
set(gca,'XDir','reverse')

% Determination of the optimal number of latent variables using cross-validation
% Classification Toolbox 7.0 – Locate the 'plsdacompsel' function on the computer

cd('C:\...')
res = plsdacompsel(Xtrainp(:, indices),ytrain,'none','cent','vene',5,'bayes')

% Visualization of the number of latent variables and classification errors
subplot(2,1,1)
plot(1:length(res.er),res.er,'b',1:length(res.er),res.er,'ro')
ylabel('Classification Error Rate','fontsize',14)
xlabel('Number of Latent Variables','fontsize',14)
grid on

subplot(2,1,2)
plot(1:length(res.not_ass),res.not_ass,'b',1:length(res.not_ass),res.not_ass,'ro')
ylabel('Unassigned Samples','fontsize',14)
xlabel('Number of Latent Variables','fontsize',14)
grid on

% Optimal number of latent variables = 8

% PLS-DA model development
% Required functions: plsdacv, plsdafit, plsdapred, and calc_class_param
% Locate these functions on the computer

cd('...')
nvl = 8;
cv = plsdacv(Xtrainp(:, indices),ytrain,nvl,'msc','cent','vene',5,'bayes')
model = plsdafit(Xtrainp(:, indices),ytrain,nvl,'msc','cent','bayes',1)

% Model Application – Model Performance Metrics
pred = plsdapred(Xtestp(:, indices),model)
class_param_train = calc_class_param(model.class_calc,ytrain)
erro_rate_train = 1-class_param_train.accuracy
class_param_test = calc_class_param(pred.class_pred,ytest)
erro_rate_test = 1-class_param_test.accuracy


%% =========================================================
% PLS-DA - PERFORMANCE METRICS AS A FUNCTION OF LATENT VARIABLES
%% =========================================================

% CONFIGURATION
maxLV = 10;
LV_escolhida = 8;

% Use previously preprocessed data
Xtr = double(Xtrainp(:,indices));
Xte = double(Xtestp(:,indices));

ytr = ytrain(:);
yte = ytest(:);

% Identify the existing classes
classes = unique([ytr; yte]);
nClasses = length(classes);

% Limit the maximum number of latent variables
maxLV = min([maxLV, size(Xtr,1)-1, size(Xtr,2)]);

% Create the dummy response matrix for PLS-DA
Ytr = zeros(length(ytr),nClasses);

for c = 1:nClasses
    Ytr(:,c) = double(ytr == classes(c));
end

% Mean-centering of the training data
mediaX = mean(Xtr,1);
mediaY = mean(Ytr,1);

Xc = bsxfun(@minus,Xtr,mediaX);
Yc = bsxfun(@minus,Ytr,mediaY);

% Apply the same mean-centering parameters to the test set
Xteste = bsxfun(@minus,Xte,mediaX);

% Initialize matrices to store performance metrics
SEN = NaN(maxLV,nClasses);
SPE = NaN(maxLV,nClasses);
FPR = NaN(maxLV,nClasses);
FNR = NaN(maxLV,nClasses);

% Initialize matrices to store PLS2 model parameters
W = zeros(size(Xc,2),maxLV);
P = zeros(size(Xc,2),maxLV);
Q = zeros(nClasses,maxLV);

Xres = Xc;
Yres = Yc;

%% =========================================================
% ITERATIVE EXTRACTION OF LATENT VARIABLES
%% =========================================================

for lv = 1:maxLV

    % Extract the latent component using SVD
    S = Xres' * Yres;
    [U,D,V] = svd(S,'econ');

    w = U(:,1);

    % Calculate the score vector
    t = Xres*w;
    tt = t'*t;

    if tt < 1e-12
        warning('No additional latent variables could be extracted.');
        maxLV = lv-1;
        break;
    end

    % Calculate the loading vectors
    p = (Xres'*t)/tt;
    q = (Yres'*t)/tt;

    % Store the model parameters
    W(:,lv) = w;
    P(:,lv) = p;
    Q(:,lv) = q;

    % Deflate the X and Y residual matrices
    Xres = Xres - t*p';
    Yres = Yres - t*q';

    % Calculate the PLS regression coefficients
    Wa = W(:,1:lv);
    Pa = P(:,1:lv);
    Qa = Q(:,1:lv);

    % Use the pseudoinverse to avoid direct matrix division
    B = Wa * (pinv(Pa'*Wa) * Qa');

    % Predict the response matrix for the test set
    Yprev = bsxfun(@plus,Xteste*B,mediaY);

    % Assign each sample to the class with the highest predicted response
    [~,ind] = max(Yprev,[],2);
    yprev = classes(ind);

    % Calculate class-wise performance metrics
    for c = 1:nClasses

        % True positives
        TP = sum((yte == classes(c)) & ...
                 (yprev == classes(c)));

        % True negatives
        TN = sum((yte ~= classes(c)) & ...
                 (yprev ~= classes(c)));

        % False positives
        FP = sum((yte ~= classes(c)) & ...
                 (yprev == classes(c)));

        % False negatives
        FN = sum((yte == classes(c)) & ...
                 (yprev ~= classes(c)));

        % Calculate sensitivity and false negative rate
        if (TP + FN) > 0
            SEN(lv,c) = TP/(TP+FN);
            FNR(lv,c) = FN/(TP+FN);
        end

        % Calculate specificity and false positive rate
        if (TN + FP) > 0
            SPE(lv,c) = TN/(TN+FP);
            FPR(lv,c) = FP/(TN+FP);
        end

    end

    fprintf('PLS-DA with %d latent variables completed.\n',lv);

end

%% =========================================================
% CALCULATION OF MEAN PERFORMANCE METRICS
%% =========================================================

SEN = SEN(1:maxLV,:);
SPE = SPE(1:maxLV,:);
FPR = FPR(1:maxLV,:);
FNR = FNR(1:maxLV,:);

% Calculate macro-averaged metrics across classes
% Requires all classes to be represented in the test set
SEN_media = mean(SEN,2)*100;
SPE_media = mean(SPE,2)*100;
FPR_media = mean(FPR,2)*100;
FNR_media = mean(FNR,2)*100;

% Organize the results
LV = (1:maxLV)';

resultados = [LV SEN_media SPE_media ...
              FPR_media FNR_media];

%% =========================================================
% GENERATION OF A GROUPED BAR CHART
%% =========================================================

figure;

dados = [SEN_media SPE_media FPR_media FNR_media];

h = bar(LV,dados,'grouped');

% Define bar colors
set(h(1),'facecolor',[0.10 0.45 0.75]);
set(h(2),'facecolor',[0.20 0.65 0.35]);
set(h(3),'facecolor',[0.90 0.35 0.25]);
set(h(4),'facecolor',[0.85 0.65 0.15]);

xlabel('Number of Latent Variables','fontsize',13);
ylabel('Rate (%)','fontsize',13);

title('PLS-DA Performance as a Function of Latent Variables');

legend('SEN','SPE','FPR','FNR', ...
       'location','northeastoutside');

set(gca,'xtick',LV);
ylim([0 100]);
grid on;
box on;


%% =========================================================
% DISPLAY PLS-DA PERFORMANCE RESULTS IN OCTAVE
%% =========================================================

fprintf('\n========================================\n');
fprintf(' PLS-DA PERFORMANCE METRICS BY LATENT VARIABLE\n');
fprintf('========================================\n');

fprintf('\n LV     SEN      SPE      FPR      FNR\n');

for i = 1:maxLV

    fprintf('%3d   %7.2f  %7.2f  %7.2f  %7.2f\n', ...
        LV(i),SEN_media(i),SPE_media(i), ...
        FPR_media(i),FNR_media(i));

end


%% =========================================================
% PERFORMANCE RESULTS FOR THE PLS-DA MODEL WITH 8 LVs
%% =========================================================

if LV_escolhida <= maxLV

    fprintf('\n========================================\n');
    fprintf(' PLS-DA MODEL WITH %d LVs\n',LV_escolhida);
    fprintf('========================================\n');

    fprintf('Sensitivity (SEN): %.2f %%\n', ...
            SEN_media(LV_escolhida));

    fprintf('Specificity (SPE): %.2f %%\n', ...
            SPE_media(LV_escolhida));

    fprintf('False Positive Rate (FPR): %.2f %%\n', ...
            FPR_media(LV_escolhida));

    fprintf('False Negative Rate (FNR): %.2f %%\n', ...
            FNR_media(LV_escolhida));

end

% Visualization of the VIP Plot - Using VIPCLASS
cd('...')
VIP=vipclass(model.settings.raw_data,model.settings.class,model.T,model.W,model.Q); %Vip Scores - variable importance of projection

% Visualization of the VIP Plot - Using HLINE
cd('...')
plot(num(:, indices),50*mean(Xtrain(:, indices)),'Color',[.8 .8 .8],'Linewidth',3), hold on
plot(num(:, indices),VIP,'b','Linewidth',2), hline(1,'r')
legend('Perfil do espectro médio','VIP', 'fontsize', 18,'location', 'northwest')
xlabel('Número de onda (cm^{-1})','fontsize', 22);
ylabel('VIP score', 'fontsize', 22)
set(gca,'XDir','reverse', 'FontSize', 16)
title('VIP Score', 'fontsize', 22)



% VIP Score Calculation and Visualization - Using VIPCLASS
cd('...')
VIP=vipclass(model.settings.raw_data,model.settings.class,model.T,model.W,model.Q); % Variable Importance in Projection (VIP) Scores

% VIP Score Plot Visualization - Using HLINE
cd('...')
plot(num(:, indices),50*mean(Xtrain(:, indices)),'Color',[.8 .8 .8],'Linewidth',3), hold on
plot(num(:, indices),VIP,'b','Linewidth',2), hline(1,'r')
legend('Mean Spectral Profile','VIP Scores', ...
       'fontsize',18,'location','northwest')
xlabel('Wavenumber (cm^{-1})','fontsize',22);
ylabel('VIP Score','fontsize',22)
set(gca,'XDir','reverse','FontSize',16)
title('VIP Scores','fontsize',22)