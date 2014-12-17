% repeat miniblock type (1:3) for it's length
% concat as long vector indicating trial type (tt)
function tt=mg_trialTypeVec(v)
 tt=zeros(1,sum(sum(v)));
 s=1;
 for vi=1:size(v,2)
   for ei=1:size(v,1)
     e=s+v(ei,vi)-1;
     tt(s:e)=ei;
     s=e+1;
   end
 end
end

%!test
% tt=mg_trialTypeVec([1 1 1; 2 2 2; 3 3 3])
% assert ( all( tt == [1   2   2   3   3   3   1   2   2   3   3   3   1   2   2   3   3   3]))
% assert( length(tt)==(3+2+1)*3 )
% assert( nnz(tt==3)==9 )
% assert( nnz(tt==2)==6 )
% assert( nnz(tt==1)==3 )
