
%%%% fonction calculant l entropie pour une distribution discrete

function entrop=entropie(vecteur_entree)
entrop=0;
for i=1:length(vecteur_entree)
    entrop=entrop-vecteur_entree(i)*log2(vecteur_entree(i));   
end
