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


%!test
%! s=[1 4 10 ]
%! e=[3 9 11 ]
%! [avail,needchange] = mg_findAvailable(s,e,nback,taken)
