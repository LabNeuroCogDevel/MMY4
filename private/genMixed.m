% generate mixed block from 
%  N          total trials
%  n_etypes   number mini block types
%  n_bocks    total number of mini blocks
%
%20141217 - initial
%20150217 - move nbk logic to nbkMatchSettings
%20250417 - add MAXREPS_ACROSS_SWITCH and loop to force
%
% generate a mixed block of N trials
% with n_etype mini block types
% with a total of n_blocks mini blocks
% where wm/nback has nprobe probes
%  and we have to recall "nback" numbers 
%  to correctly respond on a probe
%
function [ttvec, nbk,inf,cng] = genMixed(N,etypes,n_blocks,nprobe,nback)
 %N=120; n_etype=3; n_blocks=24;  
 %nprobe=12; nback=2;
 n_etype = length(etypes);
 t_trlblk= N/n_etype;   %40: total trials per block
 mu      = N/n_blocks;  %5 : average num trials in each miniblock
 n_mini  = t_trlblk/mu; %8 : number of miniblocks of each type 
                        %6   when no nback
 MAXREPS_ACROSS_SWITCH = 3;
 fprintf('\n# genMixed: %d total over %d blocks and %d types (%d/type) with %d trials per block\n',...
         N, n_blocks, n_etype, t_trlblk, mu);

 % generate miniblock trial counts
 % v = 3x12 matrix (row for each block type, column for each block length)
 %   -- this is overkill, could just make one long vector
 %      but this way we could change the mu for each mini
 v=zeros(n_etype,n_mini);
 for i=1:n_etype;
   % WF20150303
   % we want all types to have same distribution of mini block sizes
   % so minlen will be constant across all types
   minlen=3;
   %if i==1;
   %   minlen=nback+1;
   %else
   %   minlen=1;
   %end
   
   % this is nothing but a shuffle now 20150303
   v(i,:) = mg_blockvec(mu,n_mini,minlen);
 end

 
 % zip the blocks
 % so we have vec of 1 if nback
 % and 2 if inf
 ttvec = mg_trialTypeVec(v);

 NBK_TTi = strmatch('Nback',etypes);
 INF_TTi = strmatch('Interfere',etypes);
 CNG_TTi = strmatch('Congruent',etypes);

 % 20250417 - too many in a row!?
 %   should generate correct responses first (a la py code)
 %   but current code makes that tricky.
 %   both genInterfereSeq and genNbackSeq use shuffle_maxrep
 %   but they dont see each other
 %   so here's another loop to check
 %   NB. this makes switch repeats unlikely (rep of 2 + rep of 2)
 %       so allow 4 in a row if across a switch?
 maxiterations=1000;
 i=0;

 while i < maxiterations

    %% generate sequences
    [inf.seq, inf.seqi] = ...
        genInterfereSeq(t_trlblk, 0);
    % 20250417WF - 0 => disable semi-congruent (like '1 2 1')

    [cng.seq, junk, cng.seqi ] = ...
        genNbackSeq(t_trlblk,0,0);

    nbk = nbkMatchSettings(t_trlblk,nprobe,nback,v);

    % build correct keys
    all_seq=zeros(1,N);
    all_seq(ttvec==INF_TTi) = inf.seqi;
    all_seq(ttvec==CNG_TTi) = cng.seqi;
    if NBK_TTi,
        all_seq(ttvec==NBK_TTi) = nbk.seqi;
    end

    if max_reps_seen(all_seq) <= MAXREPS_ACROSS_SWITCH, break, end
    i=i+1;
 end

 if i >= maxiterations
   error('mix block has too many repeats after 1000 shuffles')
 end

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

%!test 'each type has the same distribution of miniblock lengths'
%%% ugly run length encode
%  find all indexes of a value
%  find indexes where they start to change 
%    and where they stop changing
%  get the diff of those indexes as run length
%  sort b/c we dont care about order
%  make sure the mean is the same as the first row
%  to ensure all values are the same
%! for i=unique(ttvec)
%!   idx=find(ttvec==i); 
%!   change=[1 find(diff(idx)>1)+1]; 
%!   s=idx(change); 
%!   e=idx([find(diff(idx)>1) length(idx)]);
%!   b(i,:)=sort((e-s)+1);
%! end
%! assert( all(  mean(b)==b(1,:)  ) )
