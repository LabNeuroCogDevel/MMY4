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
function [ randIdx, nbackseq, isnback, intseq ] = ...
            genEventMixed(n,nbmu,nimu)
  
   nbnum  = 2;
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
      nblocks=max(minblocknum,nNback/nbmu + round(2*bsizevar*rand(1)) - bsizevar);
      nbckblocksof=ceil(exprnd(nbmu-2,nblocks,1))+2;

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
   ncanbenback  = sum(nbckblocksof-nbnum)
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
     isnback(fin_s:(fin_s+fin_l))=[ 0 0 isnback_aft2(isn_s:(isn_s+isn_l)) ];
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
%% test number is nback
%!test
%!  n=120; nbmu=4; nimu=2;
%!  nNback=round(n/(nbmu+nimu)*nbmu);
%!  [ randIdx, nbackseq, isnback, intseq ] = genEventMixed(n,nbmu,nimu)
%!  nNbackBlock = length(nbackseq);
%   % half of possible nbacks are nbacks, 20 for 120:4:2
%!  assert(nnz(isnback), (nNback - nNbackBlock*2 )/2 ) 
%
%
