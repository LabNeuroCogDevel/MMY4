% find available indexs given start,stop and taken
% inputs are all indexes
%
% BAD probes:
%   - too early in a sequence: must be at least nback in before see a probe
%   - too late     "         : must not end with a probe, else switch is not memory 
%   - too many     "         : only one probe per nback, every probe is at least nback from another
%   - first probe must be 3rd in

function [available,needchange] = mg_findAvailable(s,e,nback,taken)

 % min number checked in genMixed
 nbksettings = getSettings('nbk');
 maxConsecutiveProbe= nbksettings.maxConsProbe;

 nblock=length(s);
 %maxProbes=sum(floor((e-s-1)/2)); % WF20150122 - max if no consecutive probes
 maxProbes=sum(floor((e-s-1)/2)+1); % allowing for consec probes:2->2,3->2...5->3,6->4
 maxProbes=maxProbes - max(0,nblock-maxConsecutiveProbe); % we lose the +1 for each bock if no more consec blocks

 if length(taken) > maxProbes
   [s;e],
   error('want %d probes, but I think the max with these %d blocks (mean length %d) is %d', ...
          length(taken), nblock, mean(e-s+1), maxProbes);
 end



 if ~all(s(2:end) > e(1:(end-1))) || any(s>e)
   error('providing overlapping or out-of-order start and end block indices');
 end

 avail=cell(nblock,1);
 goodtakes=cell(nblock,1);
 needchange=zeros(1,0);
 for i=1:nblock
   % from nback into the start to the end of the miniblock
   % also cannot end on a probe
   probeslots=(s(i)+nback):(e(i)-1);

   %WF20150121: not every sequence needs an nback probe
   %if isempty(probeslots)
   %  error('there are no good slots for nback (%d) probes given between s,e %d,%d',nback, s(i),e(i))
   %end

   % what have we already taken inside this window
   % that we should have
   inrangetakes=intersect(taken,probeslots);
   % do NOT remove any slots that are taken -- these pop out in bad v taken
   % remove any slots that would mean reacalling an nback,
   % or recalling more than one nback in a sequence
   blockprobe = findBlockedProbes(s(i),e(i),inrangetakes,nback);
   
   % do we have any goodtakes overlapping with blocked probe positions
   % ...we should remove those from good takes
   uglytakes = intersect(inrangetakes,blockprobe);
   goodtakes{i} =setdiff(inrangetakes, uglytakes);
   % redo finding blocked probes -- remove the blocked probes from bad takes
   blockprobe = findBlockedProbes(s(i),e(i),goodtakes{i},nback);

   % remove probes we cant take from available
   blockbeforetaken = findBlockedProbes(s(i),e(i),goodtakes{i},nback,@minus);

   % list all available positions for this block
   avail{i}=setdiff(probeslots,[ goodtakes{i} blockprobe blockbeforetaken] );

   %% finished setting which are good (slots availabe to be picked)
   %  now need to say which are bad   (slots picked poorly -- hopefully only initial case)

   %% the first nback is not as soon as possible
   musthave=s(i)+nback;
   if e(i)-s(i)>=nback && ~any(taken==musthave)
     % remove anything that would conflict witht the must have
     % and add the must have index
     avail{i}=[musthave, avail{i}( avail{i} > musthave+nback ) ];

     % remove any of the taken that conflict with the musthave 
     goodtakes{i} = goodtakes{i}( goodtakes{i} > musthave+nback ) ;
   end



 end

 % ugly hack to get cell into vector
 avail =cell2mat(cellfun( @(x) x(:),avail ,'UniformOutput',0))';
 goodtakes=cell2mat(cellfun( @(x) x(:), goodtakes,'UniformOutput',0))';
   
 %% if we're over max number of probes
 %  remove consecutive probes from the good takes list 
 consProbesI = find(diff(goodtakes)==1)+1;
 nConsProbes = length(consProbesI);
 while nConsProbes > maxConsecutiveProbe
   % pick a probe in the middle, maximize space between consecutive probes
   probeidx=consProbesI( floor(nConsProbes/2) );
   % remove from good takes list
   removed = goodtakes(probeidx);
   goodtakes(probeidx)=[];

   % add back +/- nback to avail
   % actual range
   r=[]; for xi=1:length(s), r=[r s(i):e(i)]; end
   % add the intersect of the range and the previously 
   % blocked-to-avoid-double-probe-resp slots
   avail=[avail, intersect(removed + nback.*[-1,1] , r) ];

   % re-callculate bounding condition variables
   consProbesI = find(diff(goodtakes)==1)+1;
   nConsProbes = length(consProbesI);
 end

 %% guaranty minProbes: in genMixed

 % all the good stuff
 ga = [goodtakes  avail ];
 % hack: rather than build ranges, include some that should never be matched
 allidxs = [1:e(end)];
 bad = setdiff(allidxs, ga);
 needchange = intersect(bad,taken);

 % we can take out taken now that we've used avail to make bad
 reserved=[ taken blockbeforetaken ];
 available=setdiff(avail,reserved);

 if length(needchange) > length(available)
   error('have %d nbk probe slots to change but only %d available ', ...
       length(needchange), length(available) )

   %WF 20150121 -- this leads to endless looping in genMixed
   %  % redo them all
   %  needchange=taken;
   %  reps=floor((e-s-1)/2);
   %  available = [];
   %  for i=1:nblock
   %    available = [ available, [ [2:2:(reps(i)*2)]+s(i) ] ];
   %  end

   %  if(length(available) < length(taken))
   %    error('need to change more positions (%d) than have available (%d)!', ...
   %       length(needchange), length(available) );
   %  end
 end

end

% given a start index, end index, taken index, and how many back a recall happens
% return all of the indexes that cannot be a probe (too close to taken probe)
function blockprobe = findBlockedProbes(s,e,takes,nback,varargin)

   % what direction to calc blockprobe, @minus or @plus
   if isempty(varargin)
     func=@plus;
   else
     func=@minus;
   end

   blockprobe=[];
   if ~isempty(takes)
     %return % dont care about consecutive probe (WF20150121)
     nbmask   = repmat(nback,1,length(takes))';  % just look for double probes
     %nbmask   = repmat([1:nback]',1,length(takes)); %WF20150121- this means no probe within nback from any other probe
     blockprobe= bsxfun(func,takes,nbmask);
     % only makes sense to block what is in the range of possible selection
     blockprobe=blockprobe(blockprobe>=s&blockprobe<=e)';
   end
end

%!test 'nothingWrong'
%! [avail,needchange] = mg_findAvailable(1,4,2,3);
%! assert( isempty(needchange) )

%!test 'nothingWrongMultipleBlocks'
%! [avail,needchange] = mg_findAvailable([1 10],[4 15],2,[3 12]);
%! assert( isempty(needchange) )

%!test 'nothingWrongMultipleX2'
%! [avail,needchange] = mg_findAvailable([1 10],[4 17],2,[3 12 16]);
%! assert( isempty(needchange) )

%!test 'change double probe'
%! [avail,needchange] = mg_findAvailable(1,7,2,[ 3 3+2 ]);
%! assert(needchange, 5)
%! assert(avail, [4 6])


%!test 'perfectlyConstrained'
%                                     %  s,e,n,probeVec
%! [avail,needchange] = mg_findAvailable(1,4,2,3);
%! assert( isempty(needchange) )
%! assert( isempty(avail)  )

%!test 'almostAllAvail'
%! [avail,needchange] = mg_findAvailable(3,12,2,[11]);
%! assert( isempty(needchange) )
%! %assert(avail, [5 8]  ) % if we only allow . . X . . X, not X X . . X 
%! assert(avail, [5 8 10]  )  % allowing consecutive probe

%!test 'does not start with nback probe'
%! [avail,needchange] = mg_findAvailable(1,5,2,[4]);
%! assert(needchange,4 )
%! assert(avail, [3]  )

%!test 'tooCloseToStart'
%! [avail,needchange] = mg_findAvailable(1,5,2,[2]);
%! assert(needchange,2 )
%! assert(avail, [3]  )

%!test 'bad ending'
%! [avail,needchange] = mg_findAvailable(1,5,2,[5]);
%! assert(needchange,5 )
%! assert(avail, [3]  )

%!test 'bad start, bad ending'
%! [avail,needchange] = mg_findAvailable(1,9,2,[2,9]);
%! assert(needchange,[2,9] )
%! assert(avail, [3 6 7 8]  )

%20150122 WF - if using idx 3, 4 is now usable (b/c we allow consecutive probes now)
% %!test 'dont reinclude back blocked probes'
% %! [avail,needchange] = mg_findAvailable([1 10],[5 11],2,[3]);
% %! assert(~any(avail==4))


%!test 'tooCloseToStartInThird'
%! nback= 2;
% pretend blocks are  1-3, 4-9, 10-11
%! s    = [1 7  20 ]; % block starts at 1, 4 and 10
%! e    = [5 15 21 ]; % block ends   on 3, 9 and 11
%! taken= [3 9  20];  % we set probes on index 3, 6,and 10
%   10 is not 2 from 11 -- needs to be changed!
%! [avail,needchange] = mg_findAvailable(s,e,nback,taken);
%! assert(needchange, 20)


%!test 'tooManyConsecutiveProbes'
%! [avail,needchange] = mg_findAvailable(1,30,2,[ 3 4 7 8 11 12 15 16]);
%! assert(length(needchange),1) % dont care which one we try to change, just that we change it

