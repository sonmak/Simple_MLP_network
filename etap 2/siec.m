
%%
clc
clear 
close all

%% CZĘŚĆ USTALENIA PARAMETRÓW SIECI

%% wczytywanie wektorów wejściowych i pożądanych wartości neuronów wyjściowych
load('data.mat');

%% przechodzimy z typu table do tablic, żeby ułatwić sobie pracę z przetwarzaniem danych
dataTreningX = table2array(dataTreningX);
dataTreningY = table2array(dataTreningY)';
dataTestX = table2array(dataTestX);
dataTestY = table2array(dataTestY)';

%% liczba neuronów w warstwie ukrytej
numberOfHidden = 5;

%% generujemy losowe wagi dla naszej sieci z przedziału [-0.25, 0.25]
W1 = 0.5*rand(numberOfHidden, size(dataTreningX,2)) - 0.25;
W2 = 0.5*rand(size(dataTreningY,1), numberOfHidden) - 0.25;

%% ustalenie parametrów sieci
mu = 0.005;  %learning rate
epokaMax = 2800;  %liczba epoch

%% szykamy odpowiednich wag dla naszej sieci
[e, W1, W2] = UpdateWeight(@BackPropError, W1, W2, dataTreningX,dataTreningY, ...
                           @Tanh, @Sigmoid, @TanhDerivative, @SigmoidDerivative, mu, epokaMax);

%% CZĘŚĆ TESTOWA

%% rozwiązanie dla danych testujących
out = FindOut(W1, W2, dataTestX, @Tanh, @Sigmoid);
N = size(out,2);                                    %ile mamy zdiagnozowanych osób ma wyjściu
%% wektor wyjściowy przerzutowany na same 0 i 1
transformed = Transform(out);  

%% oblicznie skuteczności sieci
count = 0;
for n = 1 : N
    if transformed(1, n) == dataTestY(1, n)           %jeśli wartość wyjścia sieci jest równa wartości prawdziwej to dodaj 1
        count = count + 1;
    end
end 
precent = (count/N)*100;                              %procentowa poprawność wykrycia choroby

%%
trueClasses = zeros(1, N);                            %prealokacja pamieci na wektor klas prawdziwych
expectedClasses = zeros(1, N);                        %prealokacja pamieci na wektor klas oczekiwanych

for n = 1 : N
    if dataTestY(1, n) == 0 
        trueClasses(1, n) = 1;
    elseif dataTestY(1, n) == 0 
        trueClasses(1, n) = 2; 
    end
    
    if transformed(1, n) == 0 
        expectedClasses(1, n) = 1;
    elseif transformed(1, n) == 0 
        expectedClasses(1, n) = 2;
    end
end 

%% wyciąganie wartości specyficzności i czułości
test = classperf(trueClasses,expectedClasses);

%% przebieg błędu w zależności od liczby iteracji
%fig = Plotter(e);

%% szukamy doposowanych wartości współczynników wag dla naszej sieci
function [e, W1, W2] = UpdateWeight(ImproveWeightFun, W1, W2, X, D, ...
                                        ActivateFunHidden, ActivationFunOut, ...
                                        DerivativeFunHidden, DerivativeFunOut, mu, epochMax)
    errorsArray=zeros(1, epochMax);                          %prealokacja pamieci na wektor blędu dla danej epoki
    for epochCurrent = 1 : epochMax                          %dla danej epoki zaktualizuj wartości wag sieci
        [errorsTemp, e, W1, W2] = ImproveWeightFun(W1, W2, X, D, mu, ActivateFunHidden, ActivationFunOut, ...
                                               DerivativeFunHidden, DerivativeFunOut, epochCurrent, epochMax, ...
                                               errorsArray);

        errorsArray(epochCurrent)=sum(errorsTemp)/size(X,1); %wartość błędu dla danej epoki
    end
    
end

%% funkcja opisująca wstęczną porpogację
function [errorsTemp, e, W1, W2] = BackPropError(W1, W2, X, D, mu, ActivationFunHidden, ActivationFunOut, ...
                                                DerivativeFunHidden, DerivativeFunOut, epochCurrent, epochMax,  errorArray)
    
    r = randperm(size(X,1));                    %losowy wektor uczący
    e = 0;
    error = 1e-4;                               %przewidywana wartosc blędu  
    errorsTemp = zeros(1,size(X,1));            %prealokacja pamieci na wektor blędu dla danej epoki
   
    for k = 1:size(X,1)
        x = X(r(k), :)';                        %wybranie ktory wektor ma zostac podany na sieć
        d = D(r(k));                            %wybranie odpowiadającego wektora na wyjćciu
        v1 = W1*x;                              %mnożenie wektora przez macierz wag
        y1 = ActivationFunHidden(v1);           %przepuszczenie przez funkcje aktywacji
        v = W2*y1;                              %mnożenie wektora wartswy ukrytej przez macierz wag
        y = ActivationFunOut(v);                %przepuszczenie przez funkcje aktywacji
        
        errors = d - y;                         %liczenie bledu bezwzglednego
        errorsTemp(k)=sum((errors).^2)/2;       %liczenie bledu sredniokwadratowego
        
        if errorsTemp(k) < error || epochCurrent == epochMax   %sprawdzenie czy funkcja osiagneła błąd mniejszy od zakładanego bądz osiagneła maksymalną iterację
             e = errorArray;                                       
        return
        end
        
        deltaOUT = DerivativeFunOut(v) .* errors;              %sygnał błędu dla warstwy wyjściowej

        errors1 = W2'*deltaOUT;                            
        deltaIN = DerivativeFunHidden(v1) .* errors1;          %sygnał błędu dla warstwy ukrytej

        dW1 = mu*deltaIN*x';                                   %modyfikacja wag na wejsciu warstwy ukrytej
        W1 = W1 + dW1;

        dW2 = mu*deltaOUT*y1';                                 %modyfikacja wag na wyjsciu warstwy ukrytej
        W2 = W2 + dW2;
           
    end
end

%% szukanie rozwiązania dla naszej sieci
function y = FindOut(W1, W2, X, ActivateFunHidden, ActivateFunOut)
    N = size(X, 1); 
    y = zeros(1, N);                     %wektor wyjściowy, pierwsza pozycja - odpowiedź na pobudzenie pierwszym wektore, druga - drugim itd.
    for k = 1 : N
        x = X(k, :)';                   %wybranie ktory wektor ma zostac podany na siec
        v1 = W1*x;                      %mnożenie wektora przez macierz wag
        y1 = ActivateFunHidden(v1);     %przepuszczenie przez funkcje aktywacji
        v = W2*y1;                      %mnożenie wektora wartswy ukrytej przez macierz wag
        y(k) = ActivateFunOut(v);       %przepuszczenie przez funkcje aktywacji
    end
end

%% funkcja aktywacji - hiberboliczna
function y = Tanh(v)
    y = (exp(v)-exp(-v))./(exp(v)+exp(-v));         %wzór na funkcję hiberboliczną tanh
end

%% funkcja aktywacji -  sigmoidalna
function y = Sigmoid(v)
    y = 1./(1+exp(-v));                             %wzór na funkcję sigmoidalną
end

%% pochodna funkcji aktywacji - hiberboliczna
function d = TanhDerivative(v)
    d = 1-((exp(v)-exp(-v))./(exp(v)+exp(-v))).^2;  %wzór na pochodną funkcji hiberbolicznej tanh
end

%% pochodna funkcji aktywacji -  sigmoidalna
function d = SigmoidDerivative(v)
    d = 1./(1+exp(-v)).*(1 - 1./(1+exp(-v)));       %wzór na pochodną funkcji sigmoidalnej
end

%% funkcja, która przerzuca wartości wektora wyjściowego na 0 i 1
function t = Transform(out)
    prog = 0.45;                                    %ustawienie progu
    t = zeros(size(out,1), size(out, 2));           %prealokacja pamieci na wektor skadający się z 0 i 1
    for n = 1 : size(out,2)
        if out(1, n) < prog
            t(1, n)=0;
        elseif out(1, n) > prog
            t(1, n)=1;
        end 
   end  
end

%% funkcja rysująca przebieg błędu w zależności od liczby iteracji
function f = Plotter(e)
    f = figure;
   
    figure(1)
    plot(1:size(e, 2), e)
    title('Przebieg uczenia sieci')
    xlabel('Iteracja')
    ylabel('Błąd')
    axis([0 size(e, 2) 0.08 0.25])
end
