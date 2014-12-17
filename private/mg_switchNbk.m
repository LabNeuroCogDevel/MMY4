
% switch two nbk sequences
% hopefully move one in a bad position
% to one in a good position
function nbk = mg_switchNbk(nbk,old,new,nback)
 for f=fieldnames(nbk)';
    f=f{1};
    o=nbk.(f)(old);
    nbk.(f)(old) = nbk.(f)(new);
    nbk.(f)(new)=o;
 end
 idx=old;
 % are we a probe/nback?
 % NB. From here there is no way to know if the seq
 % nback is in the same miniblock
 % we leave it up to the caller of this function to have
 % gotten that part right
 if nbk.bool(idx)
    nbk.seq(idx)=nbk.seq(idx-nback);
    nbk.seqi(idx)=nbk.seqi(idx-nback);
 end
end
