%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reconnaissance des echantillons inconnus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% CI DESSOUS LE FICHIER POUR L'APPRENTISSAGE
att_a_verifier=calcule_attributs('chauviere_test1.wav');

%%%%%%%%%%%%% CI DESSOUS LE FICHIER DONT LE LOCUTEUR DOIT ÊTRE VERIFIÉ
att_appris=calcule_attributs('chercheur_test1.wav');

moyenne_loc_appris=mean(att_appris); % vecteur moyenne
covariance_loc_appris=cov(att_appris); % matrice covariance


load stats_ubm;

%% calcul des scores

% Pour chaque echantillon de test,
% on calcule la log vraisemblance

score_loc_a_verifier=0; % score du modele 2
score_loc_ubm=0; % score du modele 2

for i=1:length(att_a_verifier(:,1))
    
   echantillon=att_a_verifier(i,:);
   
   score_loc_a_verifier=score_loc_a_verifier+log(gauss(moyenne_loc_appris,covariance_loc_appris,echantillon)); 
        
   score_loc_ubm=score_loc_ubm+log(gauss(moyenne_ubm,covariance_ubm,echantillon)); 
end

sprintf('log vraisemblance locuteur a verifier=%g\n',score_loc_a_verifier)
sprintf('log vraisemblance locuteur UBM=%g\n',score_loc_ubm)
