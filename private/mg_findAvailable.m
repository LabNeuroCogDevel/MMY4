% find available indexs given start,stop and taken
% inputs are all indexes
function [avail,needchange] = mg_findAvailable(s,e,nback,taken)
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


%!test 'perfectlyConstrained'
%                                     %  s,e,n,probeVec
%! [avail,needchange] = mg_findAvailable(1,3,2,3);
%! assert( isempty(needchange) )
%! assert( isempty(avail)  )

%!test 'almostAllAvail'
%! [avail,needchange] = mg_findAvailable(5,10,2,10);
%! assert( isempty(needchange) )
%! assert(avail, (5+2):9  )

%!test 'tooCloseToStart'
%! [avail,needchange] = mg_findAvailable(1,5,2,[2 5]);
%! assert(needchange,2 )
%! assert(avail, [3,4]  )


%!test 'double probe'
%! [avail,needchange] = mg_findAvailable(1,5,2,[ 3 3+2 ]);
%! assert(needchange, 5)
%! assert(avail, 4)

%!test 'tooCloseToStartInThird'
%! nback= 2;
% pretend blocks are  1-3, 4-9, 10-11
%! s    = [1 4 10 ]; % block starts at 1, 4 and 10
%! e    = [3 9 11 ]; % block ends   on 3, 9 and 11
%! taken= [3 6 10];  % we set probes on index 3, 6,and 10
%   10 is not 2 from 11 -- needs to be changed!
%! [avail,needchange] = mg_findAvailable(s,e,nback,taken);
%! assert(needchange, 10)
