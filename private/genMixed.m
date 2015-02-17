% generate mixed block from 
%  N          total trials
%  n_etypes   number mini block types
%  n_bocks    total number of mini blocks
%
%20141217 - initial
%20150217 - move nbk logic to nbkMatchSettings
%
% generate a mixed block of N trials
% with n_etype mini block types
% with a total of n_blocks mini blocks
% where wm/nback has nprobe probes
%  and we have to recall "nback" numbers 
%  to correctly respond on a probe
%
function [ttvec, nbk,inf,cng] = genMixed(N,n_etype,n_blocks,nprobe,nback)
 %N=120; n_etype=3; n_blocks=24;  
 %nprobe=12; nback=2;
 t_trlblk= N/n_etype;   %40: total trials per block
 mu      = N/n_blocks;  %5 : average num trials in each miniblock
 n_mini  = t_trlblk/mu; %8 : number of miniblocks of each type 

 % generate miniblock trial counts
 %   -- this is overkill, could just make one long vector
 %      but this way we could change the mu for each mini
 v=zeros(n_etype,n_mini);
 for i=1:n_etype;
   if i==1;
      minlen=nback+1;
   else
      minlen=1;
   end
   v(i,:) = mg_blockvec(mu,n_mini,minlen);
 end

 
 % zip the blocks
 % so we have vec of 1 if nback
 % and 2 if inf
 ttvec = mg_trialTypeVec(v);

 %% generate sequences
 [inf.seq, inf.seqi] = ...
      genInterfereSeq(t_trlblk);

 [cng.seq, junk, cng.seqi ] = ...
      genNbackSeq(t_trlblk,0,0);


 nbk = nbkMatchSettings(t_trlblk,nprobe,nback,v);

end


%% only run once for all tests
%!shared ttvec,nbk,inf,cng, N,n_etype,nprobe,n_blocks,nback,nbi,s

% 20150122 - WF - before chaning to 6 runs instead of 3
%   N=120;
%   n_etype=3;
%   n_blocks=24;
%   nprobe=10;
%   nback=2;

%! s=getSettings();
% consprobNum=  =  2; % least amount of consecutive probes
%! N=s.events.nTrl;
%! n_etype=3;
%! n_blocks=s.events.nminblocks;
%! nprobe=s.nbk.nprobe;
%! nback=s.nbk.nbnum;
%                         
%                         genMixed(60,3,12,5,2); 
%! [ttvec, nbk,inf,cng] = genMixed(N,n_etype,n_blocks,nprobe,nback);
%
%! nbi  = find(ttvec==1); 




%% did we get what we asked for

%!test assert (length(ttvec),N)

%!test assert (nnz(nbk.bool),nprobe )

%!test 'have exactly min probe number consecutive probes'
%!  probeidxs =  find(ttvec==1) .* nbk.bool ;
%!  assert( nnz(diff(probeidxs)==1), s.nbk.minConsProbe)


%%%%%%%
%% test probe never first of nbacks
%% never forces recall of previous block
%%%%%%%

%!test  'no nbacks before can remember nback'
%  % find starts
%! starts=find([Inf diff(nbi) ]>1);
%  % all the indexes that first to first+back 
%  % this grabs more than nbk -- but those idxs should be cng or inf (b/c nbk is 2)
%! idx= reshape(   starts + [0:(nback-1)]'   ,  1,[]);
%
% % might have block of single length at end
%! idx=intersect(idx,1:length(nbk.bool));
%  % none of the idxes are probes
%! assert( ~any( nbk.bool(idx) ) )




%!test  'no nbacks as last'
%  % find ends
%! nbit = find(nbi(2:end)-1 ~= nbi(1:(end-1)));
%  % all the indexes that first to first+back 
%  % none of the idxes are probes
%! assert( ~any( nbk.bool(nbit) ) )


%!test 'double nback-response'
%! doubles= nbk.bool((nback+1):end) == 1 &  nbk.bool(1:(end-nback) == 1);
%! assert( nnz(doubles), 0 )


%!test 'smallest nbk block length is > than nback'
% 1. take the diff of indexes to get 1 for consecutive, >1 for more
% 2. pad diff with Inf so we can find the edges
% 3. find indexes that are not consecutive
% 4. get the diff between them to find length
%! miniBlockLens = diff(  find(  [Inf diff(nbi) Inf] > 1  ) );
%! assert( all(miniBlockLens > nback) )
