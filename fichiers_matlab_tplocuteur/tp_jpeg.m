%***************************
%
% TP multimedia SILR 2
%
% M.Gelgon
%
%****************************

image=imread('milosevic.jpg');

% l'image est  l'origine en couleur

im_nivgris=mean(image,3); % on moyenne sur les 3 composantes
                          % pour passer de couleur a niv. de gris
colormap(gray);
imagesc(im_nivgris);
%histo(im_nivgris);

vec_colonne=reshape(im_nivgris',1,size(im_nivgris,1)*size(im_nivgris,2))'

histogramme=hist(vec_colonne,256); % 256=nombre de bins

%% calcul de l entropie de l histogramme

somme=sum(histogramme); % on normalise l'histogramme
histogramme=histogramme/somme; 

ent=entropie(histogramme);

% Codage de Huffmann




                            