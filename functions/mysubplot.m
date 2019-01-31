function h=mysubplot(i,j,k,dx,dy,pos) ;
% function h=mysubplot(i,j,k,dx,dy,pos) ;
%
% like subplot(i,j,k) with size control:
% dx,dy: size of each fig. if negative: size between figs
% pos=[X0,Y0,DX,DY]: total frame of all figs

if nargin<4
    dx=0 ;
end
if nargin<5
    dy=0 ;
end
if nargin<6
    pos=[0.1 0.1 0.8 0.8] ;
end

x0=pos(1);
y0=pos(2);
DX=pos(3);
DY=pos(4);

if dx>0
    sx=(DX-dx*j)/(j-1) ;
else
    sx=-dx ;
    dx=(-sx*(j-1)+DX)/j ;
end

if dy>0
    sy=(DY-dy*i)/(i-1) ;
else
    sy=-dy ;
    dy=(-sy*(i-1)+DY)/i ;
end

ic = i - floor((k-1)/j) ;
jc = mod(k-1,j)+1 ;

h=axes('position',[x0+(jc-1)*(dx+sx), y0+(ic-1)*(dy+sy), dx, dy]) ;

return