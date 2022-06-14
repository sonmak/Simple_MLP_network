%%
%Sofiya Makarenka
%Ada Kawala

%%
clc
clear 
close all

%% zczytanie danych z plików
pathToFile = "../dane/";

fileName1 = "pima.te";
fileName2 = "pima.tr";

data1 = reader(pathToFile, fileName1);
data2 = reader(pathToFile, fileName2);

clear fileName1 fileName2 pathToFile

%% tworzenie struktur dla danych testowych i trenujących
%utworzenie nazw pół dla struktury
columnHeadings = {'npreg', 'glu', 'bp', 'skin', 'bmi', 'ped', 'age', 'type'};

%konwertacja cell - structure
dataTest = cell2struct(data1, columnHeadings, 2);
dataTrening = cell2struct(data2, columnHeadings, 2);

%% numeryczne przetwarzanie struktury
dataTest =  numericalConverter(dataTest);
dataTrening = numericalConverter(dataTrening);

%usuwanie nienumeryczniego polu
dataTest = rmfield(dataTest,'type');
dataTrening = rmfield(dataTrening,'type');

%% tworzenie struktur końcowych
%dane wejściowe testowe
tempor1X.npreg = dataTest.npreg;
tempor1X.glu = dataTest.glu;
tempor1X.bp = dataTest.bp;
tempor1X.skin = dataTest.skin;
tempor1X.bmi = dataTest.bmi;
tempor1X.ped = dataTest.ped;
tempor1X.age = dataTest.age;

dataTestX = struct2table(tempor1X);
%dane wyjściowe testowe
tempor1Y.numericType = dataTest.numericType;

dataTestY = struct2table(tempor1Y);

%dane wejściowe treningowe
tempor2X.npreg = dataTrening.npreg;
tempor2X.glu = dataTrening.glu;
tempor2X.bp = dataTrening.bp;
tempor2X.skin = dataTrening.skin;
tempor2X.bmi = dataTrening.bmi;
tempor2X.ped = dataTrening.ped;
tempor2X.age = dataTrening.age;

dataTreningX = struct2table(tempor2X);
%dane wyjściowe treningowe
tempor2Y.numericType = dataTrening.numericType;

dataTreningY = struct2table(tempor2Y);

%czyszczenie niepotrzebnych danych
clear data1 data2 columnHeadings tempor1X tempor1Y tempor2X tempor2Y dataTest dataTrening 
%% funkcja odpawiadająca za zcztytanie plików
function cellArray = reader(pathToFile,fileName)
    %połączenie nazwy pliku i ścieżki względnej
    file = fullfile(pathToFile, fileName);

    fileID = fopen(file, 'r');
    
    %bezpośrednie zczytanie plików z danymi
    cellArray = textscan(fileID,'%f %f %f %f %f %f %f %s','HeaderLines', 1);
    
end

%% funkcja która konwertuje nienumeryczne dane znajdujące się w polu type
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