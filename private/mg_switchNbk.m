
% switch two nbk sequences
% hopefully move one in a bad position
% to one in a good position
% NB !!! if isprobe, probably has the wrong sequence!
function nbk = mg_switchNbk(nbk,old,new)
 for f=fieldnames(nbk)';
    f=f{1};
    o=nbk.(f)(old);
    nbk.(f)(old) = nbk.(f)(new);
    nbk.(f)(new)=o;
 end
end
