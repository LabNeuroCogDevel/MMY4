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
            genMixEvents(n,nbmu,nimu,nbnum)
  
   nNback = ceil(n/(nbmu+nimu)*nbmu);
   nInter = n-nNback; % should be close to n/(nbmu+nimu)*nimu

   % get partions of interference and nback
   [ nbkv, infv ] = genSeqLengths(n,nbmu,20,1)
   N_nbk = sum(nbkv);
   N_inf = sum(infv);

   % get sequences
   [inf.seq,inf.i]             = genInterfereSeq(N_inf);
   [nbk.seq, nbk.recal, nbk.i] = genNbackSeq(N_nbk);

   % rearrange nbk
   for 


 
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
