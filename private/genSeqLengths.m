%
% return vector of block lengths 
%  exp distributed blocks of interference and nback-recall
%
% need as input: 
%  N       total sequences (inf+nback)
%  nNback  total number of nbacks
%  nbmu    mean length of nback miniblock
%  breaks  how many transitions should we have?
%  nbnum   how many back are we tryign to recall, n of nback
%
%output
%   nbkblocksof  vector of nback miniblock length
%   infblocksof  vector of intrf miniblock length
%
function [nbckblocksof, infblocksof] = ...
 genSeqLengths(N,nbmu,breaks,nbnum)

   nNback = nbmu * breaks;
   nInter=N-nNback;
   if(nInter<breaks)
    error('of %d total events, %.f nbacks for %d blocks does not leave enough room (%.1f) for interference',N,nbmu,breaks,nInter);
   end
   nimu= round(nInter/breaks)
   N,nNback, nInter, nbmu, nimu


   minblocknum=breaks; % how many mini block transitions (task switches)
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

end

% Octave tests `test genSeqLengths`
%!test 
%!   [b, i] = genSeqLengths(102,3,20,1);
%    ## NBACK
%    # we matched our mean 
%!   assert ( round(mean(b)), 3 )
%    # we have the correct number of breaks 
%!   assert ( length(b)>=20 )
%
%    # INTERFERENCE
%    # we matched our mean for inf
%!   assert ( round(mean(i)), round( (102-3*20)/20) )
%    # we have the correct number of breaks for inf
%!   assert ( length(i)>=20 )
%
%    ## OVERALL
%    # we have n trials 
%!   assert ( sum([b;i]), 102)
%    # no negative blocks
%!   assert ( min([b;i])>0 )
