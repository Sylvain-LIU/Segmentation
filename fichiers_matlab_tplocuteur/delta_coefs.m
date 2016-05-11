function variation=delta_coefs(matrix,gap)

[nb_vectors,nb_att]=size(matrix)
variation=zeros(nb_vectors-2*gap,nb_att);

for i=1+gap:length(matrix)-gap; 
    variation(i-gap,:)=matrix(i+gap,:)-matrix(i-gap,:);
end