function [fora, super_dentro, volume] = Analise_Elipsoide(scores, centro, dimensao1, dimensao2, dimensao3)
    % Inicializa
    fora         = [];  % Índices de amostras fora do elipsoide
    super_dentro = [];  % Índices de amostras muito próximas do centro (interna)
  
    % Loop pelas amostras
    for i = 1:size(scores, 1)
        x = scores(i, 1);
        y = scores(i, 2);
        z = scores(i, 3);

        % Valor da equação do elipsoide para a amostra
        equacao = ((x - centro(1))^2 / dimensao1^2) + ...
                  ((y - centro(2))^2 / dimensao2^2) + ...
                  ((z - centro(3))^2 / dimensao3^2);

        if equacao > 1
            fora = [fora; i];                % Fora do elipsoide
        elseif equacao < 0.1
            super_dentro = [super_dentro; i];% Muito perto do centro
        end
    end

    % Volume do elipsoide
    volume = (4/3) * pi * abs(dimensao1) * abs(dimensao2) * abs(dimensao3);

end
