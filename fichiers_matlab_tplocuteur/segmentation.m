%% 
%% decoupage de la bande audio
%% sur critere de rapport de vraisemblance 
%% sur des blocs successifs

cheminwav='./';
nom_fichier='longsinfos.wav';

% parametres de la modelisation

taille_fenetre=512;
taille_bloc=taille_fenetre*130; % nb d echantillons dans un bloc
increment_fenetre=taille_fenetre*20;
calculer_derivees_mfcc=0; % pas utile pour SILR

% variables administratives du logiciel
fin_de_fichier=0;
premiere_paire=1;
indice_boucle=1;

rapport=ones(1000,2); % 1ere valeur : rapport, 2eme valeur : time instant

% extraction des caracteristiques du fichier traite
taille=wavread([cheminwav nom_fichier],'size');     
[y,fs,nbits]=wavread([cheminwav nom_fichier],[1,2]);    % y: sample data;   fs: sample rate

duree_secondes=taille(1)/fs;    % the time size of the audio
duree_bloc=taille_bloc/fs;          % the time size of a block

like=ones(10,1);
while (fin_de_fichier==0)
    
    %%%%%%%%%%%%%%%%%%
    %
    %
    % ci-dessous, on distingue la premiere paire de bloc et les suivantes.
    % En effet, l'increment de la fenetre glissante etant plus faible que la largeur des fenetres
    % on peut eviter de recalculer une partie des vecteurs d'attributs.
    %
    %%%%%%%%%%%%%%%%%%
    
    if (premiere_paire==1) % cas de la premiere paire de blocs
   
        bloci.index_debut=1;
        bloci.index_fin=taille_bloc;
        bloci.attributs=calcatt([cheminwav nom_fichier],calculer_derivees_mfcc,taille_fenetre,bloci.index_debut,bloci.index_fin);
        
        bloci.moyenne=mean(bloci.attributs);
        bloci.covariance=cov(bloci.attributs);
        bloci.log_vrais=log(gauss(bloci.moyenne,bloci.covariance,bloci.attributs)); %return a gauss distribution
        
        
        blocj.index_debut=bloci.index_fin+1;
        blocj.index_fin=blocj.index_debut+taille_bloc-1; 
        blocj.attributs=calcatt([cheminwav nom_fichier],calculer_derivees_mfcc,taille_fenetre,blocj.index_debut,blocj.index_fin);
 
        blocj.moyenne=mean(blocj.attributs);
        blocj.covariance=cov(blocj.attributs);
        blocj.log_vrais=log(gauss(blocj.moyenne,blocj.covariance,blocj.attributs));
        premiere_paire=0;
        
    else
                
        blocj.index_debut = blocj.index_debut + increment_fenetre
        blocj.index_fin   = blocj.index_fin   + increment_fenetre;
        nouveaux_attributs=calcatt([cheminwav nom_fichier],calculer_derivees_mfcc,taille_fenetre,blocj.index_fin-increment_fenetre+1,blocj.index_fin);
        nb_vecteurs_nouveaux=size(nouveaux_attributs,1);
        
        bloci.index_debut = bloci.index_debut + increment_fenetre;
        bloci.index_fin   = bloci.index_fin   + increment_fenetre;
        % on translate vers la gauche les colonnes de la matrice d'att qui sont les plus recentes
        % ce faisant, on ecrase les colonnes les plus anciennes (qui sont a l'extreme gauche)
        
        bloci.attributs(1:size(bloci.attributs,1)-nb_vecteurs_nouveaux,:) = bloci.attributs(nb_vecteurs_nouveaux+1:size(bloci.attributs,1),:);
        % on remplace les colonnes d extreme droite par les plus anciennes colonnes de Bloc j
        
        bloci.attributs(size(bloci.attributs,1)-nb_vecteurs_nouveaux+1:size(bloci.attributs,1),:) = blocj.attributs(1:nb_vecteurs_nouveaux,:);
        
        bloci.moyenne=mean(bloci.attributs);
        bloci.covariance=cov(bloci.attributs);
        bloci.log_vrais=log(gauss(bloci.moyenne,bloci.covariance,bloci.attributs));
           
        blocj.attributs(1:size(blocj.attributs,1)-nb_vecteurs_nouveaux,:)= blocj.attributs(nb_vecteurs_nouveaux+1:size(blocj.attributs,1),:);
        blocj.attributs( size(blocj.attributs,1) - nb_vecteurs_nouveaux+1 : size(blocj.attributs,1) , : ) = nouveaux_attributs;
         
        blocj.moyenne=mean(blocj.attributs);
        blocj.covariance=cov(blocj.attributs);
        blocj.log_vrais=log(gauss(blocj.moyenne,blocj.covariance,blocj.attributs));
         
    end
    
    bloc_union.index_debut=bloci.index_debut;
    bloc_union.index_fin=blocj.index_fin;
    dimension_atti=size(bloci.attributs);
    dimension_attj=size(blocj.attributs);
    nb_att=size(bloci.attributs,2);
    nb_veci=size(bloci.attributs,1);
    nb_vecj=size(blocj.attributs,1);
    bloc_union.attributs=ones(nb_veci+nb_vecj,nb_att);
    bloc_union.attributs(1:nb_veci , : )=bloci.attributs;
    bloc_union.attributs(nb_veci+1:nb_veci+nb_vecj , : )=blocj.attributs;
    bloc_union.moyenne=mean(bloc_union.attributs);
    bloc_union.covariance=cov(bloc_union.attributs);
    bloc_union.log_vrais=log(gauss(bloc_union.moyenne,bloc_union.covariance,bloc_union.attributs));
      
  
    %%% calcul du rapport de vraisemblance
    
    rapport(indice_boucle,1)=sum(bloci.log_vrais) + sum(blocj.log_vrais) - sum(bloc_union.log_vrais);
    rapport(indice_boucle,2)=(bloci.index_fin+blocj.index_debut)/2/fs;
  
    indice_boucle=indice_boucle+1;
    
     if (blocj.index_debut>19700000)
         fin_de_fichier=1;
     end
end % de la boucle qui parcourt toute la bande audio

plot(rapport(:,2),rapport(:,1))


