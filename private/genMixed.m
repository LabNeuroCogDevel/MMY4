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
function [ttvec, nbk,inf,cng] = ...
  genMixed(N,n_etype,n_blocks,nprobe,nback)
 %N=120; n_etype=3; n_blocks=24;  
 %nprobe=12; nback=2;
 t_trlblk= N/n_etype;  %40: total trials per block
 mu     = N/n_blocks; %5 : average num trials in each miniblock
 n_mini = t_trlblk/mu; %8 : number of miniblocks of each type 

 % generate miniblock trial counts
 v=zeros(n_etype,n_mini);
 for i=1:n_etype;
   v(i,:)=blockvec(mu,n_mini);
 end

 
 % zip the blocks
 % so we have vec of 1 if nback
 % and 2 if inf
 ttvec = trialTypeVec(v);

 %% generate sequences
 [nbk.seq, nbk.bool, nbk.seqi] = ...
      genNbackSeq(t_trlblk,nprobe,nback);
 [inf.seq, int.seqi] = ...
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
 [avail,bad]=findAvailable(s,e,nback,find(nbk.bool));

 % remove all the bad with good
 maxitr=1000; itr=0;
 while ~isempty(bad)
    % get a random new position
    new=Shuffle(avail);
    % switch the bad for the new
    nbk=switchNbk(nbk,bad(1),new(1));
    %fprintf('changing %d for %d\n',bad(1),new(1));
    %s,e,find(nbk.bool)
    
    % redo finding available/bad index
    [avail,bad]=findAvailable(s,e,nback,find(nbk.bool));

    if isempty(avail) && ~isempty(bad)
       error('generating nback seq: no more good indexes')
    end
    itr=itr+1;
    if itr>maxitr
       error('tried %d times to fix nback seq; giving up', maxitr)
    end
 end
 

end


%%% Support Functions

% switch two nbk sequences
% hopefully move one in a bad position
% to one in a good position
% NB !!! if isprobe, probably has the wrong sequence!
function nbk = switchNbk(nbk,old,new)
 for f=fieldnames(nbk)';
    f=f{1};
    o=nbk.(f)(old);
    nbk.(f)(old) = nbk.(f)(new);
    nbk.(f)(new)=o;
 end
end

% find available indexs given start,stop and taken
% inputs are all indexes
function [avail,needchange] = findAvailable(s,e,nback,taken)
 avail=zeros(1,0);
 for i=1:length(s)
   % from nback into the start to the end of the miniblock
   goodslots=(s(i)+nback):e(i);
   % what have we already taken inside this window
   % that we should have
   goodtakes=intersect(taken,goodslots);
   % do NOT remove any slots that are taken -- these pop out in bad v taken
   % remove any slots that would mean reacalling an nback
   availslots = setdiff(goodslots,goodtakes+nback);

   % append onto what are already available
   % conditionals to try to avoid intermitent error:
   %  e.g. "error: horizontal dimensions mismatch (0x2 vs 1x5)"
   if isempty(availslots)
     continue
   end

   if isempty(avail)
    avail=availslots;
   else
    avail=[avail availslots ];
   end
 end

 bad = setdiff(1:e(end), avail);
 needchange = intersect(bad,taken);
 % we can take out taken now that we've used avail to make bad
 avail=setdiff(avail,taken);

end

function v=blockvec(mu,n_mini)
 maxiter=1000; % stop after 1000 attempts

 % total should be average * repeats
 t_trlblk=mu*n_mini;

 % init loop vars
 d=Inf; v=0; iter=0;
 % go until diff is 0 and there is no 0
 while d~=0 || ~all(v>0);
   v=round(exprnd(mu,1,n_mini));
   d=sum(v)-t_trlblk;
   iter=iter+1;
   if iter > maxiter
     error('could not generate vector of mini block sizes in reasonable time %.2f %.2f', mu, n_mini);
   end
 end
end

% repeat miniblock type (1:3) for it's length
% concat as long vector indicating trial type (tt)
function tt=trialTypeVec(v)
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



% test assert (sum(blockvec(5,8))==40)
% test
%  genMixed(120,3,24,12,2)
%  s=[1    3    4   13   19   23   34   38]
%  e=[2    3   12   18   22   33   37   40]
