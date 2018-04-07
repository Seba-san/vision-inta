da=size(Distancia);
C=[0 0];
for i=2:da(2)
    
    
    if sum(Distancia{i}(:,3))==0 % no tiene que tner una actualizacion el frame siguiente
        OR1=Distancia{i-1}(:,1:2);
        OR2=Distancia{i}(:,1:2);
        a=size(OR1(:,1));b=size(OR2(:,1));
        aa=max([a b]); V1=zeros(aa,2);V2=zeros(aa,2);
        V1(1:a,:)=OR1; V2(1:b,:)=OR2;
        nz1=find(V1(:,1)~=0);dd=zeros(1,aa);dd(nz1)=1;
        nz2=find(V2(:,1)~=0);dd2=zeros(1,aa);dd2(nz2)=1;
        a=dd&dd2;a2=xor(dd,dd2);
        clear OR1;clear OR2;
        OR1=V1(a,:); OR2=V2(a,:);
        if V2(a2,1)~=0
            ORF2=V2(a2,:);
        else
            ORF2=[0 0];
        end    
        
        [x,y] = pol2cart(pi/2-OR1(:,2),OR1(:,1));
        [x2,y2] = pol2cart(pi/2-OR2(:,2),OR2(:,1));
        
        figure(1)
        H=histogram2(x-x2,y-y2);
       
        [d,dd]= find(H.Values==max(max(H.Values)));
        if sum(size(d))==2
            kx=find(x-x2<H.XBinEdges(d)+H.BinWidth(1)&x-x2>H.XBinEdges(d));
             ky=find(y-y2<H.YBinEdges(dd)+H.BinWidth(2)&y-y2>H.YBinEdges(dd));
           % dC=[mean(x(kx)-x2(kx)) mean(y(ky)-y2(ky)) ];
        
        else
            kx=find(x-x2>-10000);
            ky=find(y-y2>-10000);
           % dC=[mean(x(kx)-x2(kx)) mean(y(ky)-y2(ky)) ];
            

        end
%            dC=[mean(x(kx)-x2(kx)) mean(y(ky)-y2(ky)) ];
       % [C1,ORF1]=ConversionMarcosRef(OR1(kx,:),OR2(kx,:),[0 0]);
%        figure(2)
%         plot(x(kx),y(kx),'bx');ylim([0 4000]);xlim([-2000 2000])
%         hold on
%         plot(x2(kx),y2(kx),'rx')
%         hold off
        figure(1)
        plot(x,y,'bx');ylim([0 4000]);xlim([-2000 2000])
        hold on
        plot(x2,y2,'rx')
        hold off
 C=C+dC;
%  C=C+C1;
%  figure(2)
%   hold on
%         plot(C(1),C(2),'rx'); text(C(1),C(2),num2str(i))
%         hold off
    pause()
    
    
    end
    
    
end
hold off