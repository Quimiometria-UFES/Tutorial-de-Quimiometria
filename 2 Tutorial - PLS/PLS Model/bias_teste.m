function teste = bias_teste(valor_real,valor_previsto,pvalor)
% Teste para erros sistemáticos - bias
% input:
%    valor_real: valor de referência
%    valor_previsto: resultado calculado (modelado)
%    pvalor: valor de teste segundo a distribuição t-studente (padrão 0.05)
% 
% teste = bias_teste(valor_real,valor_previsto,pvalor);
%
% Paulo R. Filgueiras 03/12/2012
%
if nargin==2
    pvalor=0.05;
end
teste.bias=(sum(valor_real-valor_previsto))/length(valor_real);
teste.SVD=sqrt(sum((valor_real-valor_previsto-teste.bias).^2)/(length(valor_real)-1));
teste.t=(abs(teste.bias)*sqrt(length(valor_real)))/teste.SVD;
%% teste para erro sistemático
pvalor=pvalor/2;
teste.ttab=abs(tinv(pvalor,(length(valor_real)-1)));
disp('  ')
if teste.t < teste.ttab
    s = sprintf('tcal = %g < ttab = %g',teste.t,teste.ttab); disp(s)
    disp('Erros sistemáticos NÃO significativos')
else
    s = sprintf('tcal = %g > ttab = %g',teste.t,teste.ttab); disp(s)
    disp('Os erros sistemáticos são significativos')
end
disp('  ')

teste.pvalue=2*(1-tcdf(teste.t,(length(valor_real)-1)));
