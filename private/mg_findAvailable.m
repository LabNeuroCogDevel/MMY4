% find available indexs given start,stop and taken
% inputs are all indexes
%
% BAD probes:
%   - too early in a sequence: must be at least nback in before see a probe
%   - too late     "         : must not end with a probe, else switch is not memory 
%   - too many     "         : only one probe per nback, every probe is at least nback from another

function [available,needchange] = mg_findAvailable(s,e,nback,taken)
 nblock=length(s);


 avail=cell(nblock,1);
 goodtakes=cell(nblock,1);
 needchange=zeros(1,0);
 for i=1:nblock
   % from nback into the start to the end of the miniblock
   % also cannot end on a probe
   goodslots=(s(i)+nback):(e(i)-1);

   %WF20150121: not every sequence needs an nback probe
   %if isempty(goodslots)
   %  error('there are no good slots for nback (%d) probes given between s,e %d,%d',nback, s(i),e(i))
   %end
  
   % what have we already taken inside this window
   % that we should have
   inrangetakes=intersect(taken,goodslots);
   % do NOT remove any slots that are taken -- these pop out in bad v taken
   % remove any slots that would mean reacalling an nback,
   % or recalling more than one nback in a sequence
   blockprobe = findBlockedProbes(inrangetakes,nback);
   
   % do we have any goodtakes overlapping with blocked probe positions
   % ...we should remove those from good takes
   uglytakes = intersect(inrangetakes,blockprobe);
   goodtakes(i) =setdiff(inrangetakes, uglytakes);
   % redo finding blocked probes -- remove the blocked probes from bad takes
   blockprobe = findBlockedProbes(goodtakes{i},nback);

   avail{i}=setdiff(goodslots,[ goodtakes{i} blockprobe] );

 end

 bad = setdiff(1:e(end), [ goodtakes{:} avail{:}]);
 needchange = intersect(bad,taken);

 % we can take out taken now that we've used avail to make bad
 available=setdiff([avail{:}],taken);

 if length(needchange) > length(available)
   error('need to change more positions (%d) than have available (%d)!', ...
      length(needchange), length(available) );
 end

end

function blockprobe = findBlockedProbes(takes,nback)
   if isempty(takes)
     blockprobe=[];
   else
     nbmask   = repmat([1:nback]',1,length(takes));
     blockprobe= bsxfun(@plus,nbmask, takes);
     blockprobe=blockprobe(:)';
   end
end

%!test 'nothingWrong'
%! [avail,needchange] = mg_findAvailable(1,4,2,3);
%! assert( isempty(needchange) )

%!test 'nothingWrongMultiple'
%! [avail,needchange] = mg_findAvailable([1 10],[4 14],2,[3 13]);
%! assert( isempty(needchange) )


%!test 'perfectlyConstrained'
%                                     %  s,e,n,probeVec
%! [avail,needchange] = mg_findAvailable(1,4,2,3);
%! assert( isempty(needchange) )
%! assert( isempty(avail)  )

%!test 'almostAllAvail'
%! [avail,needchange] = mg_findAvailable(5,10,2,9);
%! assert( isempty(needchange) )
%! assert(avail, (5+2):8  )

%!test 'tooCloseToStart'
%! [avail,needchange] = mg_findAvailable(1,5,2,[2]);
%! assert(needchange,2 )
%! assert(avail, [3,4]  )

%!test 'bad ending'
%! [avail,needchange] = mg_findAvailable(1,5,2,[5]);
%! assert(needchange,5 )
%! assert(avail, [3,4]  )

%!test 'bad start, bad ending'
%! [avail,needchange] = mg_findAvailable(1,5,2,[2,5]);
%! assert(needchange,[2,5] )
%! assert(avail, [3,4]  )


%!test 'double probe'
%! [avail,needchange] = mg_findAvailable(1,7,2,[ 3 3+2 ]);
%! assert(needchange, 5)
%! assert(avail, 6)

%!test 'tooCloseToStartInThird'
%! nback= 2;
% pretend blocks are  1-3, 4-9, 10-11
%! s    = [1 7  20 ]; % block starts at 1, 4 and 10
%! e    = [5 15 21 ]; % block ends   on 3, 9 and 11
%! taken= [4 10  20];  % we set probes on index 3, 6,and 10
%   10 is not 2 from 11 -- needs to be changed!
%! [avail,needchange] = mg_findAvailable(s,e,nback,taken);
%! assert(needchange, 20)
%! assert(~any(avail==3))
