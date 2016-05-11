%% TP Reconnaissance de locuteur
%% SILR 3
%% 
%% M.Gelgon

%clear % efface les variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcule les attributs des donnes d'apprentissage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Calcul des attributs des donnees d apprentissage');

att_loc1=calcule_attributs('chauviere_apprend.wav');
att_loc2=calcule_attributs('chauviere_test1.wav');
att_loc3=calcule_attributs('chauviere_test2.wav');
att_loc4=calcule_attributs('chercheur_apprend.wav');
att_loc5=calcule_attributs('chercheur_test1.wav');
att_loc6=calcule_attributs('chercheur_test2.wav');
att_loc7=calcule_attributs('invite_train.wav');
att_loc8=calcule_attributs('villers_train.wav');

att_ubm=[att_loc1;att_loc2;att_loc3;att_loc4;att_loc5;att_loc6;att_loc7;att_loc8];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calcul les modeles gaussiens des locuteurs appris
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Calcul des modeles de locuteurs');

moyenne_ubm=mean(att_ubm); % vecteur moyenne
covariance_ubm=cov(att_ubm); % matrice covariance

%moyenne_loc2=mean(att_loc2);
%covariance_loc2=cov(att_loc2);

save stats_ubm moyenne_ubm covariance_ubm;
