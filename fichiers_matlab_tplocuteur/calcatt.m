%
% M.Gelgon. Pour toute reclamation mettre 1 euro dans la serrure.
%
%%% passer -1 et -1 en param pour lire tout le fichier audio.

function attributes=calcule_attributs(filename,compute_derivatives,taille_fenetre,start,theend)

if (start==-1 & theend==-1) % si on lit tout le fichier audio
  [y,fs,nbits]=wavread(filename);
else  
[y,fs,nbits]=wavread(filename,[start theend]);
end

% In this file, MFCC attributes are computed,
% along with their differential
% and the attribute vector is built.

% convert stereo to mono by averaging, if necessary
if (size(y,2)>1)
y=(mean(y'))';
end

% compute MFCC features

nb_coefs=13; % this is HARD CODED !!!
overlap_in_successive_windows=0.5; % 0.5 => increment is half of window size

if (compute_derivatives)
    nb_attributes=nb_coefs*2;
else
    nb_attributes=nb_coefs;
end

coefs=mfcc(y,taille_fenetre,taille_fenetre*overlap_in_successive_windows,nb_coefs);

attributes=zeros(length(coefs),nb_attributes);  % allocate size

attributes(:,1:nb_coefs)=coefs;

if (compute_derivatives==1)
    
    % compute 1st-order temporal derivatives
    % literate says they make a 15% improvement in recognition
    time_gap_derivative=1;
    delta=delta_coefs_with_padding(coefs,time_gap_derivative);
    attributes(:,nb_coefs+1:nb_attributes)=delta;
    attributes(:,1:nb_coefs)=delta;
end

% 2nd-order derivatives are not implemented.
% literature says they make +8% improvement
% but beware the curse of dim and cpu cost, so probably not useful.

