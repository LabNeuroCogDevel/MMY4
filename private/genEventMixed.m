%  IN
% n             number of trials in total
% nbmu          mean number of nbacks in a row
% nimu          mean number of interference in a row
%
%  OUT
% randIdx(1:n)  1=>nback,2=>interfere
% nbackseq(1:x) cell of cellstring sequences for nback
% isnback(1:x)  logical is trial nback the same as this trial
% intseq(1:y)   cell of cellstrings sequences for interference
%
% x=n/(nbmu+nimu)*nbmu
% y=n/(nbmu+nimu)*nimu
function [ randIdx, nbackseq, isnback, intseq ] = ...
            genEventMixed(n,nbmu,nimu)
  
   nNback = ceil(n/(nbmu+nimu)*nbmu);
   nInter = n-nNback; % should be close to n/(nbmu+nimu)*nimu


   %% Block Lengths
   % exp. dist blocks of nbacks min is 3
   blocksof=0;
   bsizevar=2; % number of bins can varry from average by 2
               % but we need a min of 20 switches
   while sum(blocksof) ~= nNback 
      nblocks=max(20,nNback/nbmu + round(2*bsizevar*rand(1)) - bsizevar);
      blocksof=ceil(exprnd(nbmu-2,nblocks,1))+2;
   end

   % do the same for Interference
   infblocksof=0;
   while sum(infblocksof) ~= nInter
      infblocksof=ceil(exprnd(nimu,nblocks,1));
   end

   %% distribution of key press
   % before determining the sequences, lets evently distribute button pushes

end
