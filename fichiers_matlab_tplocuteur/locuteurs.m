%% TP Reconnaissance de locuteur
%% 
%% M.Gelgon


clear % efface les variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcule les attributs des donnes d'apprentissage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Calcul des attributs des donnees d apprentissage');

att_loc1=calcule_attributs('invite_train.wav');
att_loc2=calcule_attributs('villers_train.wav');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcul les modeles gaussiens des locuteurs appris
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Calcul des modeles de locuteurs');

moyenne_loc1=mean(att_loc1); % vecteur moyenne
covariance_loc1=cov(att_loc1); % matrice covariance

moyenne_loc2=mean(att_loc2);
covariance_loc2=cov(att_loc2);

