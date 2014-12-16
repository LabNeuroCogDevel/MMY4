%     IN
% n             number of trials in total
% nbmu          mean number of nbacks in a row
% nimu          mean number of interference in a row
%
%     OUT
% randIdx(1:n)  1=>nback,2=>interfere
% nbackseq(1:x) cell of cellstring sequences for nback
% isnback(1:x)  logical is trial nback the same as this trial
% intseq(1:y)   cell of cellstrings sequences for interference
%
%     WHERE
% x=n/(nbmu+nimu)*nbmu % total number nback
% y=n/(nbmu+nimu)*nimu % total number interf
%
function [ randIdx, nbackseq, isnback, intseq,nblocks ] = ...
            genEventMixed(n,nbmu,nimu,nbnum)
  
   nNback = ceil(n/(nbmu+nimu)*nbmu);
   nInter = n-nNback; % should be close to n/(nbmu+nimu)*nimu
   minblocknum=20; % how many mini block transitions (task switches)
   maxIterations=1000;


   %% Block Lengths
   % exp. dist blocks of nbacks min is 3
   nbckblocksof=0;
   bsizevar=2; % number of bins can varry from average by 2
               % but we need a min of 20 switches
   intcnt=0;
   while sum(nbckblocksof) ~= nNback 
      randadjust=round(2*bsizevar*rand(1)) - bsizevar;
      
      % dont want less than minblocks
      % but will be varaible about the number of blocks
      nblocks=max(minblocknum, nNback/nbmu + randadjust);
                   

      nbckblocksof=ceil(exprnd(nbmu-nbnum,nblocks,1))+nbnum;

      intcnt=intcnt+1;
      if intcnt > maxIterations
        error(['hit max iterations (%d) in nback gen!\n'...
               'maybe you should change min block (%d) num'],...
               maxIterations, minblocknum);
      end
   end

   % do the same for Interference
   % but use the same number of blocks
   infblocksof=0;

   intcnt=0;
   while sum(infblocksof) ~= nInter
      infblocksof=ceil(exprnd(nimu,nblocks,1));

      intcnt=intcnt+1;
      if intcnt > maxIterations
        error('hit max iterations (%d) in interf gen!', maxIterations);
      end
   end

   %% for nback, we need half to be same as 2 back
   % first 2 of each nback block cannot count (have to be no nback)
   ncanbenback  = sum(nbckblocksof-nbnum);
   isnback_aft2 = Shuffle(repmat(0:1,1,ceil(ncanbenback/2)));
   isnback_aft2 = isnback_aft2(1:ncanbenback);

   %% setup which event type will be on each trial
   %   and when nback type is actually same as a trial 2 back
   randIdx=Inf(n,1);
   isnback=Inf(nNback,1);
   e=0;
   for b=1:nblocks
     s=e+1;
     e=e+infblocksof(b);
     randIdx(s:e)=2;

     s=e+1;
     e=e+nbckblocksof(b);
     randIdx(s:e)=1;

     % pick half of the trials (after first 2) to
     % be same as 2 blocks back
     fin_l=nbckblocksof(b)-1;
     isn_l=nbckblocksof(b)-1 - nbnum;
     fin_s=sum(nbckblocksof(1:b)) - fin_l ;
     isn_s=sum(nbckblocksof(1:b)-nbnum) - isn_l;
     isnback(fin_s:(fin_s+fin_l))=[ repmat(0,1,nbnum) isnback_aft2(isn_s:(isn_s+isn_l)) ];
   end
   



   %% distribution of key presses
   % need to do sequentially, so use for loop
   trialkeycnt=ones(1,n);
   isnbackidx=find(randIdx==1);
   for i=fliplr(find(isnback==1)')
      % coding error if we hit this
      if trialkeycnt( isnbackidx(i) ) == 0
         error('key assignment: %d trial key count already cleared once!', i);
      end

      % trial nbnum back gets this trials key count
      trialkeycnt( isnbackidx(i)-nbnum ) = ...
                          trialkeycnt( isnbackidx(i)-nbnum ) ...
                        + trialkeycnt( isnbackidx(i));

      % this trials key count goes to zero
      trialkeycnt( isnbackidx(i) ) = 0;
   end

   % check that we counted all the trials
   if mean(trialkeycnt)~=1 % same as sum(trialkeycnt) == n
     error('key assignment: not all trials are counted');
   end

   %% assign keys
   %  - shuffle trials up
   %  - break trials into 3 groups with the same key press sum
   %  - assing a key to each group
   %  - check
   keysets= getSettings('keys');
   nkeys=length(keysets.string);
   keys=Inf(1,n);
   [ cnt, ki ] = Shuffle(trialkeycnt);
   cntm = mod(cumsum(cnt),round(n/nkeys));
   splitidx=find(cntm <= 4); % find where we are 4 or less over
   ends=0; endidx=1;
   % for each index, check if it is far enough away from first turnover
   for i=splitidx
     if i-ends(endidx) < (n/nkeys)/2 
       continue
     end
     endidx=endidx+1;
     ends(endidx)=i;
   end
   ends(nkeys+1)=n; % last group ends with end of all

   % use ends to assign keys
   for i=1:length(ends)-1
      srng=ends(i)+1;
      erng=ends(i+1);
      keys( ki(srng:erng) ) = i;
   end
   ok=keys;
   ok( isnbackidx(isnback==1) ) = 0;
   nseen=histc(ok,0:nkeys);

   % replace nback keys
   % this trial is nback, grab the other key
   % IN FOR LOOP b/c must be done sequentially
   % replace nback keys
   for i=find(isnback==1)
      % this trial is nback, grab the other key
      keys( isnbackidx(i) ) = keys( isnbackidx(i)-nbnum );
   end

   % check
   nseen=histc(keys,1:nkeys);
   if(max(nseen)-min(nseen) > 1)
     warning('something is wrong with key generation')
   end

   %%%%% make sequences
   nbackseqs= {...
                {'1','0','0'};
                {'0','2','0'};
                {'0','0','3'}...
               };
  
   
  nbackseq= nbackseqs( keys(randIdx==1) );

  intseq  = genInterference(keys(randIdx==2) ,keysets.string);



 
end

% TOTEST
%  n nback matches expected
%  n interf "
%  nback in a row is never less than 3
%  keypushes are distributed
%




%% test number nbacks occur half the time
%!test
%!  n=120; nbmu=4; nimu=2; nbnum=1;
%!  [ randIdx, nbackseq, isnback, intseq, nblocks ] = genEventMixed(n,nbmu,nimu, nbnum);
%   % half of possible nbacks are nbacks, 20 for 120:4:2
%!  nNback    = round(n/(nbmu+nimu)*nbmu);
%!  halfnBack = round((nNback - nblocks*nbnum)/2);
%!  assert(nnz(isnback), halfnBack) 
%!  %halfnBackAlt = round((length(isnback)/nblocks - nbnum)*nblocks/2 );
%!  %assert(nnz(isnback), halfnBackAlt) 



%% TEST nbacks are where they say they are
%!test
%!  n=120; nbmu=4; nimu=2; nbnum=2;
%!  [ randIdx, nbackseq, isnback, intseq, nblocks ] = ...
%!     genEventMixed(n,nbmu,nimu, nbnum);
%!  seq=cellfun(@(x) findFingerInSeq(x,{'1','2','3'}), nbackseq);
%!  isnback=find(isnback);
%!  assert(seq(isnback),seq(isnback-nbnum));



%% TEST all keys seen equally
%!xtest
%!  n=120; nbmu=4; nimu=2; nbnum=2;
%!  [ randIdx, nbackseq, isnback, intseq, nblocks ] = ...
%!     genEventMixed(n,nbmu,nimu, nbnum);
%!  seq=cellfun(@(x) findFingerInSeq(x,{'1','2','3'}), nbackseq);
%!  ob =cellfun(@(x) findOddball(x,{'1','2','3'}), intseq);
%!  cnt = histc([seq' ob],1:3);
%!  assert( max(cnt), min(cnt))



%% interference key presses are equally distributed
%!xtest
%!  n=120; nbmu=4; nimu=2; nbnum=1;
%!  [ randIdx, nbackseq, isnback, intseq, nblocks ] = ...
%!      genEventMixed(n,nbmu,nimu, nbnum);
%!  ob = cellfun(@(x) findOddball(x,{'1','2','3'}), intseq);
%!  cnt = histc(ob,1:3);
%   % all counts are the same
%!   assert( max(cnt), min(cnt))
%
%
