% mfcc.m

% Calculate cepstral coefficients for 

% sequence y, using window length N, 

% window step size M, and order P.

% Jay Land EEL6586 4/12/99

function ccep=mfcc(y,M,N,P);

NYQ=N/2;

% Triangle Filter Defs

for i=1:10

fstart(i)=(2*i)-1;

end;

fcent=fstart+2;

fstop=fstart+4;

fstart(11)=23;

fstart(12)=27;

fstart(13)=31;

fstart(14)=35;

fstart(15)=40;

fstart(16)=46;

fstart(17)=55;

fstart(18)=61;

fstart(19)=70;

fstart(20)=81;

fcent(11)=27;

fcent(12)=31;

fcent(13)=35;

fcent(14)=40;

fcent(15)=46;

fcent(16)=55;

fcent(17)=61;

fcent(18)=70;

fcent(19)=81;

fcent(20)=93;

fstop(11)=31;

fstop(12)=35;

fstop(13)=40;

fstop(14)=46;

fstop(15)=55;

fstop(16)=61;

fstop(17)=70;

fstop(18)=81;

fstop(19)=93;

fstop(20)=108;

seqlen=size(y,1);

m=0;

startpt=1;

endpt=N;

m=1;

while endpt<=seqlen
    
winseq=hamming(N).*y(startpt:endpt);

magspec=abs(fft(winseq));

for i=1:20 % Calc triangle filter outputs

for j=fstart(i):fcent(i)

filtmag(j)=(j-fstart(i))/(fcent(i)-fstart(i));

end;

for j=fcent(i)+1:fstop(i)

filtmag(j)=1-(j-fcent(i))/(fstop(i)-fcent(i));

end;
%filtmag=filtmag';
%disp('magspec');
%magspec(fstart(i):fstop(i))
%disp('filtmag');
%filtmag(fstart(i):fstop(i))
Y(i)=sum(magspec(fstart(i):fstop(i)).*filtmag(fstart(i):fstop(i))');

end;

Y=log(Y.^2);

for i=1:P

coefwin=cos((pi/20)*i*(linspace(1,20,20)-0.5))';

ccep(i,m)=sum(coefwin.*Y');

end;

m=m+1;

startpt=1+(m-1)*M;

endpt=startpt+N-1;

end;


%