
% switch two nbk sequences
% hopefully move one in a bad position
% to one in a good position
function nbk = mg_switchNbk(nbk,old,new,nback)

 %% flip new and old
 for f=fieldnames(nbk)';
    f=f{1};
    o=nbk.(f)(old);
    nbk.(f)(old) = nbk.(f)(new);
    nbk.(f)(new)=o;
 end

 %% assign display (seq) and expected key (seqi)
 % are we a probe/nback?
 % NB. From here there is no way to know if the seq
 % nback is in the same miniblock
 % we leave it up to the caller of this function to have
 % gotten that part right
 %   sort so we always pick the XXX value correct from lowest idx
 for idx=sort([old new])
   if nbk.bool(idx)
      nbk.seqi(idx)=nbk.seqi(idx-nback);
      % this will be overwritten with XXX anyway
      nbk.seq(idx)=nbk.seq(idx-nback);
   end
 end
end


%!shared nbk
%! nbk.seq = { {'a'}, {'b'}, {'c'},{'d'} };
%! nbk.seqi= [  1       2      3     4   ];
%! nbk.bool= [  1       0      0     1   ];

%!test 'no probe switch'
%!  nbk2 = mg_switchNbk(nbk,2,3,2);
%!  assert( nbk2.seqi(2), 3)
%!  assert( nbk2.seqi(3), 2)

%!test 'probe switch'
%!  nbk2 = mg_switchNbk(nbk,1,3,2)
%!  assert( nbk2.seqi(1), 3)
%!  assert( nbk2.seqi(3), 3)
%
%!  assert( nbk2.bool(1), 0)
%!  assert( nbk2.bool(3), 1)
%! nbk2.seq{3}
%!  assert( nbk2.seq{1}, {'c'})
%!  assert( nbk2.seq{3}, {'c'})
