%--------First import ¡°G_date_out¡±£¨the running result of stockfollowers.m£©into the program---------------
%--------According to ¡°G_date_out¡± to determine the number of simulated stocks, the number of days and the probability of connection ---------------
%-------- Output: G_randi, follow_dates_count:The number of consecutive follow-up days for each stock  , G_S_max_link: Maximum consecutive follow-up days between two stocks  

N=length(G_date_out{1, 1});
Days=length(G_date_out);
for i=1:length(G_date_out)
temp=G_date_out{1,i}; 
Theta(i)=sum(sum(temp))/(N*N);        
end
%-------- Start simulation and set the number of simulations ----------------------------------------------
G_randi=cell({});
for randi=1:500
G_date_out=cell({});
for k=1:Days
    G_S=zeros(N);
    G_S=int8(G_S);
    for i=1:N
        temp=rand(N,1);
        G_S(temp<=Theta(k),i)=1;
    end
    G_date_out(k)={G_S};          %  Every day's network must be saved
    disp(k)
end

stocklist=1:N;

my_leaders_num=zeros(length(stocklist),length(G_date_out));   %  Rows are stocks, columns are networks
my_followers_num=zeros(length(stocklist),length(G_date_out)); 
follow_dates_count=zeros(length(stocklist),1);                
Relax_dates_count=zeros(length(stocklist),1);                 
G_nodes_changes=zeros(length(stocklist),1);
G_S_max_link=zeros(length(stocklist));
G_S_times=zeros(length(stocklist));
for i=1:length(G_date_out)+1
     if i==length(G_date_out)+1
         G_S=zeros(N);
     else
         G_S=G_date_out{1,i} ;   
     end     
    my_leaders_num(:,i)=sum(G_S,1);  
    my_followers_num(:,i)=sum(G_S,2);  
    if i==1
        G_count=zeros(length(stocklist));            
        G_decount=zeros(length(stocklist));          
    end
       for tici=1:length(stocklist)
                  for ticj=1:length(stocklist)
       %%Compared with yesterday, there are four more possibilities: ** follow + follow, ** don¡¯t follow + follow, ** follow + don¡¯t follow, ** don¡¯t follow + don¡¯t follow
                      if G_count(tici,ticj)>0 && G_S(tici,ticj)>0       % follow + follow
                           G_count(tici,ticj)= G_count(tici,ticj)+1;               % 
                      elseif G_count(tici,ticj)==0 &&  G_S(tici,ticj)>0    %**don¡¯t follow + follow
                          G_count(tici,ticj)=1;                                    % 
                          if G_decount(tici,ticj)>0                      
                              if G_decount(tici,ticj)>size(Relax_dates_count,2)
                                  Relax_dates_count(ticj,G_decount(tici,ticj))=1;
                              else
                                   Relax_dates_count(ticj,G_decount(tici,ticj))= Relax_dates_count(ticj,G_decount(tici,ticj))+1;
                              end
                          G_decount(tici,ticj)=0;                      % 
                          end
                      elseif G_count(tici,ticj)>0 &&  G_S(tici,ticj)==0       %** follow + don¡¯t follow
                          G_decount(tici,ticj)=1;                      % 
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

G_randi(randi,1)={G_S_times};
G_randi(randi,2)={follow_dates_count};           %    lead-lag days of each stock
G_randi(randi,3)={G_S_max_link};                 %    max lead-lag days between all pairs
disp(randi);
end
