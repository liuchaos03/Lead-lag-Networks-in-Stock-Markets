%--------------Read data from excel
%--------------Output：Stkcd  Trddt  Clsprc CodeN Code0

Stkcd0=[];  %Stock code
Trddt0=[]; %date
Clsprc0=[];   %Closing price

xls={'2015-2016.xlsx','2017-2018.xlsx','2019.xlsx'};

%沪市 % SSE
shee={'上海A'};
shee2={'上海A','科创板'};

% 深市 % SZSE
%shee={'深圳A','创业板'};
%shee2={'深圳A','创业板'};

for i=1:length(xls)
if i<length(xls)    
    for j=1:length(shee)
[temp,txt,~]=xlsread(xls{1,i},shee{1,j});    
Stkcd0=[Stkcd0;txt(2:end,1)];
Trddt0=[Trddt0;temp(:,1)];
Clsprc0=[Clsprc0;temp(:,2)];
    end
else
    for j=1:length(shee2)
[temp,txt,~]=xlsread(xls{1,i},shee2{1,j});    
Stkcd0=[Stkcd0;txt(2:end,1)];
Trddt0=[Trddt0;temp(:,1)];
Clsprc0=[Clsprc0;temp(:,2)];
    end
end
end

Code0=unique(Stkcd0);
CodeN=1:length(Code0);
% CodeN=CodeN-1;
Stkcd=zeros(length(Stkcd0),1);
for i=1:length(Code0)
    temp=ismember(Stkcd0,Code0(i));
    Stkcd(temp)=CodeN(i);
end
Trddt=Trddt0;
Clsprc=Clsprc0;


