function rep = replicar(nrep,nsamp)

if nargin <2
    fprintf('Deve haver inputs para nrep(número de réplicas e nsamp(número de amostras).\n')
    nrep=input('nrep=');
    nsamp=input('nsamp=');
end

 if isempty(nrep) || ~isnumeric(nrep) || isempty(nsamp) || ~isnumeric(nsamp)
     error('Número devem ser inteiros para nrep (número de réplicas) e nsamp (número de amostras)')
 elseif fix(nrep)-nrep ~=0 || fix(nsamp)-nsamp ~=0
     error('Não devem ser utilizados números decimais nestes input')
 end

%Criar um vetor com o número de amostras no conjunto de dados
samples=(1:nsamp)';
rep=zeros(nrep*size(samples,1),1);
for ki=1:size(samples,1)
    a=samples(ki,1);
    b=repmat(a,nrep,1);
    if ki>1
        kj=(nrep*ki)-(nrep-1);
        rep(kj:kj+nrep-1,1)=b;
    else
        kj=1;
        rep(kj:kj+nrep-1,1)=b;
    end
    %rep(kj:(kj+nrep)-1,1)=b;
end
