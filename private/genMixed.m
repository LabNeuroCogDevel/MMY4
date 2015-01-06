% generate mixed block from 
%  N          total trials
%  n_etypes   number mini block types
%  n_bocks    total number of mini blocks
%
%20141217 - initial
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
   v(i,:) = mg_blockvec(mu,n_mini);
 end

 
 % zip the blocks
 % so we have vec of 1 if nback
 % and 2 if inf
 ttvec = mg_trialTypeVec(v);

 %% generate sequences
 [nbk.seq, nbk.bool, nbk.seqi] = ...
      genNbackSeq(t_trlblk,nprobe,nback);
 [inf.seq, inf.seqi] = ...
      genInterfereSeq(t_trlblk);
 [cng.seq, junk, cng.seqi ] = ...
      genNbackSeq(t_trlblk,0,0);

 
 
 %% hard part!
 % look through the generated nback and make sure
 % nbacks dont happen first or second
 
 % get start and end indexes of the miniblocks
 s=[1 cumsum(v(1,1:(end-1)))+1 ];
 e=cumsum(v(1,:));

 % find where it's okay to have nbacks
 % and where bad ones are
 [avail,bad] = mg_findAvailable(s,e,nback,find(nbk.bool));

 % remove all the bad with good
 maxitr=1000; itr=0;
 while ~isempty(bad)
    % get a random new position
    new=Shuffle(avail);
    % switch the bad for the new
    nbk = mg_switchNbk(nbk,bad(1),new(1),nback);
    %fprintf('changing %d for %d\n',bad(1),new(1));
    %s,e,find(nbk.bool)
    
    % redo finding available/bad index
    [avail,bad]=mg_findAvailable(s,e,nback,find(nbk.bool));

    if isempty(avail) && ~isempty(bad)
       error('generating nback seq: no more good indexes')
    end
    itr=itr+1;
    if itr>maxitr
       error('tried %d times to fix nback seq; giving up', maxitr)
    end
 end
 

end


%% only run once for all tests
%!shared ttvec,nbk,inf,cng, N,n_etype,nprobe,n_blocks,nback
%! N=120;
%! n_etype=3;
%! n_blocks=24;
%! nprobe=12;
%! nback=2;
%                         
%! [ttvec, nbk,inf,cng] = genMixed(N,n_etype,n_blocks,nprobe,nback);

%% did we get what we asked for

%!test assert (length(ttvec),N)

%!test assert (nnz(nbk.bool),nprobe )



%%%%%%%
%% test probe never first of nbacks
%% never forces recall of previous block
%%%%%%%

%!test  'no nbacks before can remember nback'
%  % find where we are nback
%! nbi  = find(ttvec==1); 
%  % find starts
%! nbit = find(nbi(2:end)-1 ~= nbi(1:(end-1)))+1;
%  % all the indexes that first to first+back 
%! nbit
%! idx= reshape(   nbit + [0:(nback-1)]'   ,  1,[]);
%  % none of the idxes are probes
%! assert( ~any( nbk.bool(idx) ) )

