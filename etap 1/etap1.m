%%
%Sofiya Makarenka 308912
%Ada Kawala 304135

%%
clc
clear
close all

%%
%zczytanie danych z plików
pathToFile = "../dane/";

fileName1 = "pima.te";
fileName2 = "pima.tr";

data1 = reader(pathToFile, fileName1);
data2 = reader(pathToFile, fileName2);

clear fileName1 fileName2 pathToFile

%%
%tworzenie struktur dla danych testowych i trenujących

%utworzenie nazw pół dla struktury
columnHeadings = {'npreg', 'glu', 'bp', 'skin', 'bmi', 'ped', 'age', 'type'};

%konwertacja cell - structure
dataTest = cell2struct(data1, columnHeadings, 2);
dataTrening = cell2struct(data2, columnHeadings, 2);
%clear data1 data2

%% 
%numeryczne przetwarzanie struktury

dataTest =  numericalConverter(dataTest);
dataTrening = numericalConverter(dataTrening);

%usuwanie nienumeryczniego polu
dataTest = rmfield(dataTest,'type');
dataTrening = rmfield(dataTrening,'type');

%%
%podział na chorych i zdrowych
numberOfSick = 0; numberOfHealth = 0;
structureSick = struct; structureHealth = struct;

[structureSick, structureHealth, numberOfSick, numberOfHealth] = sortSickVSHealth(dataTest, structureSick, structureHealth,...
                                                                                                            numberOfSick, numberOfHealth);
[structureSick, structureHealth, numberOfSick, numberOfHealth] = sortSickVSHealth(dataTrening, structureSick, structureHealth,...
                                                                                                            numberOfSick, numberOfHealth);

%%
%zakres wartości dla każdego z pól
rangeArraySick = rangeFinder(structureSick);
rangeArrayHealth = rangeFinder(structureHealth);

%%
%średnia wartość każdej z cechy
meanSick = meanFinder(structureSick);
meanHealth = meanFinder(structureHealth);

%%
%odchylenie standardowe każdej z cechy
stdSick = stdFinder(structureSick);
stdHealth = stdFinder(structureHealth);

%%
%plotowanie wszystkich histogramów dla chorych i zdrowych

%chore
figure
h1 = histogram(structureSick.npreg);
title('Liczba ciąż');
figure
h2 = histogram(structureSick.glu);
title('Stężenie glukozy w osoczu na podstawie doustnego testu tolerancji glukozy');
figure
h3 = histogram(structureSick.bp);
title('Ciśnienie rozkurczowe krwi');
figure
h4 = histogram(structureSick.skin);
title('Grubość fałdu skóry tricepsu');
figure
h5 = histogram(structureSick.bmi);
title('Wskaźnik masy ciała');
figure
h6 = histogram(structureSick.ped);
title('Funkcja rodowodu cukrzycy');
figure
h7 = histogram(structureSick.age);
title('Wiek');

%zdrowe
figure
h8 = histogram(structureHealth.npreg);
title('Liczba ciąż');
figure
h9 = histogram(structureHealth.glu);
title('Stężenie glukozy w osoczu na podstawie doustnego testu tolerancji glukozy');
figure
h10 = histogram(structureHealth.bp);
title('Ciśnienie rozkurczowe krwi');
figure
h11 = histogram(structureHealth.skin);
title('Grubość fałdu skóry tricepsu');
figure
h12 = histogram(structureHealth.bmi);
title('Wskaźnik masy ciała');
figure
h13 = histogram(structureHealth.ped);
title('Funkcja rodowodu cukrzycy');
figure
h14 = histogram(structureHealth.age);
title('Wiek');
%%
%funkcja odpawiadająca za zcztytanie plików
function cellArray = reader(pathToFile,fileName)
    %połączenie nazwy pliku i ścieżki względnej
    file = fullfile(pathToFile, fileName);

    fileID = fopen(file, 'r');
    
    %bezpośrednie zczytanie plików z danymi
    cellArray = textscan(fileID,'%f %f %f %f %f %f %f %s','HeaderLines', 1);
    
end

%%
%funkcja która konwertuje nienumeryczne dane znajdujące się w polu type
function structure = numericalConverter(unmodifiedStructure)
    for i = 1 : size(unmodifiedStructure.type)
        if strcmp(unmodifiedStructure.type{i}, 'Yes')
            unmodifiedStructure.type(i) = {1};
        elseif strcmp(unmodifiedStructure.type{i}, 'No')
            unmodifiedStructure.type(i) = {0};
        else
            error('Data is broken');
        end
    end
    
    for i = 1 : size(unmodifiedStructure.type)
        unmodifiedStructure.numericType(i,1) = cell2mat(unmodifiedStructure.type(i));
    end
    structure = unmodifiedStructure;
end

%%
%funkcja sortująca chorych i zdrowych
function [structureSick, structureHealth, numberOfSick, numberOfHealth] = sortSickVSHealth(structure, structureSick, structureHealth,...
                                                                                                            numberOfSick, numberOfHealth)
    for i = 1 : size(structure.glu)
        if structure.numericType(i) == 0
            numberOfHealth = numberOfHealth + 1;
            structureHealth.npreg(numberOfHealth) = structure.npreg(i);
            structureHealth.glu(numberOfHealth) = structure.glu(i);
            structureHealth.bp(numberOfHealth) = structure.bp(i);
            structureHealth.skin(numberOfHealth) = structure.skin(i);
            structureHealth.bmi(numberOfHealth) = structure.bmi(i);
            structureHealth.ped(numberOfHealth) = structure.ped(i);
            structureHealth.age(numberOfHealth) = structure.age(i);
        elseif structure.numericType(i) == 1
            numberOfSick = numberOfSick + 1;
            structureSick.npreg(numberOfSick) = structure.npreg(i);
            structureSick.glu(numberOfSick) = structure.glu(i);
            structureSick.bp(numberOfSick) = structure.bp(i);
            structureSick.skin(numberOfSick) = structure.skin(i);
            structureSick.bmi(numberOfSick) = structure.bmi(i);
            structureSick.ped(numberOfSick) = structure.ped(i);
            structureSick.age(numberOfSick) = structure.age(i);
        else
            error('Data is broken');
        end
    end
end

%%
%funkcja szukająca zakres wartości 
function range = rangeFinder(structure)
    range.npreg(1,1) = min(structure.npreg);
    range.npreg(2,1) = max(structure.npreg);
    range.glu(1,1) = min(structure.glu);
    range.glu(2,1) = max(structure.glu);
    range.bp(1,1) = min(structure.bp);
    range.bp(2,1) = max(structure.bp);
    range.skin(1,1) = min(structure.skin);
    range.skin(2,1) = max(structure.skin);
    range.bmi(1,1) = min(structure.bmi);
    range.bmi(2,1) = max(structure.bmi);
    range.ped(1,1) = min(structure.ped);
    range.ped(2,1) = max(structure.ped);
    range.age(1,1) = min(structure.age);
    range.age(2,1) = max(structure.age);
end 

%%
%funkcja która oblicza średnią wartość z każdej cechy
function m = meanFinder(structure)
    m.npreg(1) = mean(structure.npreg);
    m.glu(1) = mean(structure.glu);
    m.bp(1) = mean(structure.bp);
    m.skin(1) = mean(structure.skin);
    m.bmi(1) = mean(structure.bmi);
    m.ped(1) = mean(structure.ped);
    m.age(1) = mean(structure.age);
end

%%
%funckcka zwraca odchylenie standardowe cech
function s = stdFinder(structure)
    s.npreg(1) = std(structure.npreg);
    s.glu(1) = std(structure.glu);
    s.bp(1) = std(structure.bp);
    s.skin(1) = std(structure.skin);
    s.bmi(1) = std(structure.bmi);
    s.ped(1) = std(structure.ped);
    s.age(1) = std(structure.age);
end