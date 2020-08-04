%--------You need to import data first---------------------------
%------- Output--- follow_dates_count:The number of consecutive follow-up days for each stock  , G_S_max_link: Maximum consecutive follow-up days between two stocks  
% Clsprc£ºClosing price
% Stkcd£º Stock code
% Trddt:  date
    
keyarea=0.20; %0.10,0.15,0.20,0.25,0.30£¬0.35        %Set the scope of follow
%--------Data arrangement---------------------------
stocklist=unique(Stkcd);       
stockdata=[Stkcd,Trddt,Clsprc];              
stockdata=sortrows(stockdata, [1,2]);     
temp2=stockdata(2:length(stockdata),3);      
temp=stockdata(1:length(stockdata)-1,3);     % Calculate the change
temp=(temp2-temp)./temp;
code=stockdata(:,1);
stockout=[stockdata(:,1),stockdata(:,2),[0;temp]];
for i=2:length(code)
    if code(i-1)~=code(i)       
        stockout(i,3)=0;       
    end
    disp(i);    
end

datalist=unique(stockdata(:,2));         

G_V=nan(length(datalist),length(stocklist));           % Put dates and stocks into the matrix
datalistA=[datalist;0];    
stocklistB=[stocklist;0];
for k=1:length(stockout)
    i=find(datalistA==stockout(k,2));               
    j=find(stocklistB==stockout(k,1));
    if i~=length(datalistA) && j~=length(stocklistB)
        G_V(i,j)=stockout(k,3);                         
    end
    disp(k);
end

%%
%Build the network from the second day

G_date_out=cell({});
for i=2:length(datalist)
    G_S=zeros(length(stocklist));
    Area=G_V(i-1,:);             
    for j=1:length(stocklist)
    temp=0;
        if G_V(i,j)>0
            temp=(G_V(i,j)<=Area*(1+keyarea)).*(G_V(i,j)>=Area*(1-keyarea));
        elseif G_V(i,j)<0
            temp=(G_V(i,j)>=Area*(1+keyarea)).*(G_V(i,j)<=Area*(1-keyarea));
        end
            temp=find(temp==1);
         for k=1:length(temp)
             G_S(temp(k),j)=1;
         end
    end
    G_date_out(i-1)={int8(G_S)};          %Every day's network must be saved
    disp([num2str(i),'--',num2str(sum(sum(G_S)))]);
end

my_leaders_num=zeros(length(stocklist),length(G_date_out));   %Rows are stocks, columns are networks
my_followers_num=zeros(length(stocklist),length(G_date_out)); 
follow_dates_count=zeros(length(stocklist),1);  %Record of consecutive days   %The row is each stock, the column is the number of days
Relax_dates_count=zeros(length(stocklist),1);  %
G_nodes_changes=zeros(length(stocklist),1);
G_S_max_link=zeros(length(stocklist));
G_S_times=zeros(length(stocklist));
for i=1:length(G_date_out)+1
    if i<=length(G_date_out)
    G_S=G_date_out{1,i} ;  
    my_leaders_num(:,i)=sum(G_S,1);  
    my_followers_num(:,i)=sum(G_S,2); 
    else
    G_S=zeros(length(stocklist));
    end
 
    if i==1
        G_count=zeros(length(stocklist));            
        G_decount=zeros(length(stocklist));          
    end

       for tici=1:length(stocklist)
                  for ticj=1:length(stocklist)
           %%Compared with yesterday, there are four more possibilities: ** follow + follow, ** don¡¯t follow + follow, ** follow + don¡¯t follow, ** don¡¯t follow + don¡¯t follow
                      if G_count(tici,ticj)>0 && G_S(tici,ticj)>0       %** follow + follow
                           G_count(tici,ticj)= G_count(tici,ticj)+1;              
                      elseif G_count(tici,ticj)==0 &&  G_S(tici,ticj)>0    %don¡¯t follow 
                          G_count(tici,ticj)=1;                                    
                          if G_decount(tici,ticj)>0                      
                              if G_decount(tici,ticj)>size(Relax_dates_count,2)
                                  Relax_dates_count(ticj,G_decount(tici,ticj))=1;
                              else
                                   Relax_dates_count(ticj,G_decount(tici,ticj))= Relax_dates_count(ticj,G_decount(tici,ticj))+1;
                              end
                          G_decount(tici,ticj)=0;                    
                          end
                      elseif G_count(tici,ticj)>0 &&  G_S(tici,ticj)==0       %follow + don¡¯t follow
                          G_decount(tici,ticj)=1;                    
                         if G_count(tici,ticj)>0
                              if G_count(tici,ticj)>size(follow_dates_count,2)
                                  follow_dates_count(ticj,G_count(tici,ticj))=1;
                              else
                                   follow_dates_count(ticj,G_count(tici,ticj))= follow_dates_count(ticj,G_count(tici,ticj))+1;
                              end
                                  if G_count(tici,ticj)>G_S_max_link(tici,ticj)
                                      G_S_times(tici,ticj)=G_S_times(tici,ticj)+1;
                                      G_S_max_link(tici,ticj)=G_count(tici,ticj);
                                  end
                          G_count(tici,ticj)=0;                       
                         end
                       elseif  G_count(tici,ticj)==0 &&  G_S(tici,ticj)==0     %** don¡¯t follow + don¡¯t follow
                               G_decount(tici,ticj)=G_decount(tici,ticj)+1;                 
                      end
                  end
       end
   disp(i);
end
%------calculating time----------
follow_dates_count_days=sum(follow_dates_count)./sum(sum(follow_dates_count));

