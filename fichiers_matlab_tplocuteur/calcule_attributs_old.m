
%%% passer -1 et -1 en param pour lire tout le fichier audio.

function attribute=calcule_attributs(filename)

disp('Calcul attributs MFCC ');
disp(filename);

  y=wavread(filename);


% In this file, MFCC attributes are computed,
% along with their differential
% and the attribute vector is built.

% convert stereo to mono, if necessary
if (size(y,2)>1)
y=(mean(y'))';
end

% computer MFCC

nb_coef=7;

disp('computing mfcc...');
coef=mfcc(y,512,256,nb_coef)';

% computer 1st-order differential
gap=2;
delta=delta_coefs(coef,gap);
size(delta)

attribute=zeros(length(coef),2*nb_coef);
attribute(:,1:nb_coef)=coef;
attribute(1+gap:length(coef)-gap,nb_coef+1:2*nb_coef)=delta;
% retirer les mesures de debuts et fin
% pour lesquelles le differentiel n'est pas calculable
attribute=attribute(1+gap:length(coef)-gap,:);
% Pour l'ordre 2
%attribute(:,2*nb_coef:3*nb_coef-2)=delta2;

