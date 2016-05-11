%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reconnaissance des echantillons inconnus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

att_inconnu=calcule_attributs('chercheur_test1.wav');

%% calcul des scores

% Pour chaque echantillon de test,
% on calcule la log vraisemblance

score_loc1=0; % score du modele 2
score_loc2=0; % score du modele 2

for i=1:length(att_inconnu(:,1))
    
   echantillon=att_inconnu(i,:);
   
   score_loc1=score_loc1+log(gauss(moyenne_loc1,covariance_loc1,echantillon)); 
        
   score_loc2=score_loc2+log(gauss(moyenne_loc2,covariance_loc2,echantillon)); 
end

sprintf('log vraisemblance locuteur 1=%g\n',score_loc1)
sprintf('log vraisemblance locuteur 2=%g\n',score_loc2)
