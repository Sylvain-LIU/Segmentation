%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualisation d'un sous-espace de dimension 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% les 3 axes choisis

DIM1 = 2;
DIM2 = 4;
DIM3 = 8;

figure(1);
plot3(att_loc1(:,DIM1),att_loc1(:,DIM2),att_loc1(:,DIM3),'.r');
hold on;
plot3(att_loc2(:,DIM1),att_loc2(:,DIM2),att_loc2(:,DIM3),'.b');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% visualisation de l'histogramme d'un des attributs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DIM_CHOISIE=4;
NOMBRE_BINS=20;

figure(2);
hist(att_loc1(:,DIM_CHOISIE),NOMBRE_BINS);
