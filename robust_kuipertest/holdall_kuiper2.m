keyareaALL=[0.10,0.15,0.20,0.25,0.30,0.35]; %0.10,0.15,0.20,0.25,0.30，0.35
%   Dierta=[0.1,0.01,0.001];
SSE_outkuiper_stat=zeros();
SSE_outkuiper_pval=zeros();
SZSE_outkuiper_stat=zeros();
SZSE_outkuiper_pval=zeros();

for ki=1:6  % SSE
    load(['SSE',num2str(keyareaALL(ki)),'.mat'], 'G_S_max_link');
    tmp1=G_S_max_link(:);
    tmp1=tabulate(tmp1);
    for kj=1:6
            load(['SSE',num2str(keyareaALL(kj)),'.mat'], 'G_S_max_link');
            tmp2=G_S_max_link(:);
            tmp2=tabulate(tmp2);
            [ku,n,p]=kuiper_cdf2(tmp1(:,1),tmp1(:,2),tmp2(:,1),tmp2(:,2));
            SSE_outkuiper_stat(kj,ki)=ku;
            SSE_outkuiper_pval(kj,ki)=p;
    end
end


for ki=1:6  % SZSE
    load(['SZSE',num2str(keyareaALL(ki)),'.mat'], 'G_S_max_link');
    tmp1=G_S_max_link(:);
    tmp1=tabulate(tmp1);
    for kj=1:6
            load(['SZSE',num2str(keyareaALL(kj)),'.mat'], 'G_S_max_link');
            tmp2=G_S_max_link(:);
            tmp2=tabulate(tmp2);
            [ku,n,p]=kuiper_cdf2(tmp1(:,1),tmp1(:,2),tmp2(:,1),tmp2(:,2));
            SZSE_outkuiper_stat(kj,ki)=ku;
            SZSE_outkuiper_pval(kj,ki)=p;
    end
end


function [kuiper,n,pValue]=kuiper_cdf2(x1,y1,x2,y2)
    xxi=x1;  
    yyi=y1;
    yyi=yyi./sum(yyi);
    for k=2:length(yyi)
        yyi(k)=yyi(k)+yyi(k-1);   % cdf
    end
    
        xxj=x2; 
        yyj=y2; 
        yyj=yyj./sum(yyj);
        for k=2:length(yyj)
            yyj(k)=yyj(k)+yyj(k-1);    %   cdf
        end
        
        xx=unique([xxi;xxj]);
        ki=1;
        kj=1;
        yi=zeros();
        yj=zeros();
        for k=1:length(xx)
            xi=xx(k)==xxi;
            xj=xx(k)==xxj;
            
            if sum(xi)==0
                yi(k)=yyi(ki);
            else
                 yi(k)=yyi(xi);
                 ki=find(xi==1);
            end
            if sum(xj)==0
                yj(k)=yyj(kj);
            else
               yj(k)=yyj(xj);
               kj=find(xj==1);
            end
        end
        kuiper=max(yi-yj)+max(yj-yi);
n=length(xx);
KuiperStat=kuiper;
lambda  =  max((sqrt(n) + 0.155 + 0.24/sqrt(n)) * KuiperStat, 0); % This max is useless if CDF in input is correct.
if lambda < 0.4 % Useless to compute pValue (pValue equals 1 at the 7th decimal
                % For small value of lambda some problems may also arise with sum convergence
    pValue = 1; % KuiperStat very small for this sample length: never reject H0
  %  H = 0;
    return
end

% Use the approximation in Press et al. (2007, p. 739)
fun = @(j) 2 * (4 * j.^2 * lambda^2 - 1) .* exp(-2 * j.^2 * lambda^2);
j   = 1:100; % j tends to infinity.
pValue   = sum(fun(j));
pValue(pValue < 0) = 0;
pValue(pValue > 1) = 1;

end