% repeat miniblock type (1:3) for it's length
% concat as long vector indicating trial type (tt)
function tt=mg_trialTypeVec(v)
 tt=zeros(1,sum(sum(v)));

 n_evt=size(v,1);
 n_mini=prod(size(v));
 ev=mg_eventswitch(n_evt,n_mini);
 used=ones(n_evt,1);
 s=1;
 for ei=ev'
   % block length is from event (row) ei
   % and the column of how many we've used so far
   blen = v(ei,used(ei));
   e=s+blen-1;
   tt(s:e)=ei;
   s=e+1;
   used(ei)=used(ei)+1;
 end
end

%!test
% tt=mg_trialTypeVec([1 1 1; 2 2 2; 3 3 3])
% %assert ( all( tt == [1   2   2   3   3   3   1   2   2   3   3   3   1   2   2   3   3   3]))
% assert( length(tt)==(3+2+1)*3 )
% assert( nnz(tt==3)==9 )
% assert( nnz(tt==2)==6 )
% assert( nnz(tt==1)==3 )
