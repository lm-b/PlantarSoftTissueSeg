% Cohen's kappa for feature reduction

function kappa = CohKapp(ytest, ytrain)

allvals= [ytest, ytrain];
denom= size(allvals,1)*size(allvals,2);
p0= sum( ytest==ytrain)/ denom;

for j=1:unique(ytrain)
      peall(j)= (sum(ytest==j)/denom)*(sum(ytrain==j)/denom);
end 

pe=sum(peall);
kappa=(p0-pe)/ (1-pe);
kappa=1-kappa;


end
