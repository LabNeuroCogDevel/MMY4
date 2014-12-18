% take num events and num miniblocks
% returns event vector (ev) of miniblock event order
% s.t. none in a row
%      each transition is sampled near equally
% n_evt=3, n_mini=24
function [ev switchcnt ] =mg_eventswitch(n_evt,n_mini)
  
  % we like it when things are easy
  if mod(n_mini,n_evt)
    warning('number of events (%d) doesnt go evenly into number of miniblocks (%d)',n_evt,n_mini)
  end
 
  % if we didn't care about switch directions
  %ev=repmat(1:n_evt,1,ceil(n_mini/n_evt))
  %while ~all(diff(ev)); ev=Shuffle(repmat(1:3,1,24/3)); end


  % how many switches should each have
  n_perm=factorial(n_evt);
  minseen=floor(n_mini/n_perm);
  maxevsn=minseen*(n_evt-1);

  % initialize vars
  switchcnt=zeros(n_evt);
  ev=zeros(n_mini,1);
  ev(1)=RandSample(1:n_evt);

  evlist=1:n_evt;

  for i=2:n_mini

    used=ev(i-1);
    cnt = Inf;
    toomany=1;
    % pick again -- should be while
    while cnt>=minseen || toomany
      avail = setdiff(1:n_evt,used);
      if isempty(avail)
       switchcnt,
       error('cannot compute, took a dead end path!')
      end

      ev(i) = RandSample(avail);

      scnttemp = switchcnt;
      scnttemp(ev(i-1),ev(i) )=scnttemp(ev(i-1),ev(i) ) +1;
      % totals for each event -> other event
      toomany = sum(scnttemp)>=maxevsn & sum(switchcnt,2)'>=maxevsn;
      toomany = toomany(ev(i));

      cnt = switchcnt(ev(i-1),ev(i) );
      used=[used ev(i)];
    end

    switchcnt(ev(i-1),ev(i) ) = switchcnt(ev(i-1),ev(i) ) +1;
  end


end

%!test  % we used everyone one as best we could
%! n_evt=3; n_mini=getSettings('events').nminblocks;
%! [ ev switchcnt ] =mg_eventswitch(n_evt,n_mini);
%! cnt=switchcnt(find(~eye(n_evt)));
%! diff=max(cnt) - min(cnt);
%! assert( diff <= 1 );

%%  make sure there are no repeats
%!test assert( all(diff(mg_eventswitch(3,24))) ) 

%!test  % switchcnt  is correct
%! n_evt=3; n_mini=getSettings('events').nminblocks;
%! [ ev switchcnt ] =mg_eventswitch(n_evt,n_mini);
%! cnt=zeros(size(switchcnt));
%! for i=2:length(ev)
%!  cnt( ev(i-1), ev(i) ) = 1 + cnt( ev(i-1), ev(i) );
%! end
%! assert(switchcnt==cnt);

%!test % make sure no random errors
%! n_evt=3; n_mini=getSettings('events').nminblocks;
%! for i=1:100; 
%!   [ ev switchcnt ] =mg_eventswitch(n_evt,n_mini);
%! end
