% nbkMatchSettings -- given totaltrails (n) number of probes (nProbe), 
%                     nback num (back), and vector of mini block lengths (v)
%    generate nbk object [seq, bool, seqi ]
%    use mg_findAvailable to support consProbes min/max in settings
%    use mg_switchNbk to switch out bad and good  
%
function nbk =  nbkMatchSettings(n,nProbe,back,v)
 % if we actually dont want anything, pass that through
 if n == 0
   [nbk.seq, nbk.bool, nbk.seqi] = ...
     genNbackSeq( 0,0,0);
   return
 end

 % v is matrix of miniblock lengths
 % if pure block, v is empty or 1x1 matrix (value =n)
 if isempty(v) 
  v=n;
 end
 %% generate nbacks until we meet the min probe requirement
 %  note: we might hit unusable generated miniblocks
 %   try, catch iterates through these
 nbksetting = getSettings('nbk');
 probeMin = nbksetting.minConsProbe;
 nbkitrmax=15;
 nbkitr=0; nbk.bool=[];
 while nnz(diff(find(nbk.bool))==1) < probeMin && nbkitr < nbkitrmax 
  try
    [nbk.seq, nbk.bool, nbk.seqi] = ...
         genNbackSeq(n,nProbe,back);
    
    %% hard part!
    % look through the generated nback and make sure
    % nbacks dont happen first or second
    
    % get start and end indexes of the miniblocks
    % if pure block (v=n) s=1,e=n
    s=[1 cumsum(v(1,1:(end-1)))+1 ];
    e=cumsum(v(1,:));

    % find where it's okay to have nbacks
    % and where bad ones are
    [avail,bad] = mg_findAvailable(s,e,back,find(nbk.bool));
    %keyboard

    % remove all the bad with good
    maxitr=150; itr=0;
    while ~isempty(bad)
       % get a random new position
       new=Shuffle(avail);
       % switch the bad for the new
       nbk = mg_switchNbk(nbk,bad(1),new(1),back);
       %fprintf('changing %d for %d\n',bad(1),new(1));
       %s,e,find(nbk.bool)
       
       % redo finding available/bad index
       [avail,bad]=mg_findAvailable(s,e,back,find(nbk.bool));

       if isempty(avail) && ~isempty(bad)
          error('generating nback seq: no more good indexes')
       end
       itr=itr+1;
       if itr>maxitr
          error('tried %d times to fix nback seq; giving up', maxitr)
       end

    end
 
  catch ERR
    
    warning(ERR.message);
    warning('hit unusuable random miniblock sequence, trying again');
    nbkitr=nbkitr+1
    nbk.bool=[];
  end

  if nbkitr>=nbkitrmax 
   error('Could not generate sequence, try again')
  end


end



%!test  'handles empty'
%! nbk=nbkMatchSettings(0,100,2,[1:10;1:10;1:10]);
%! assert( isempty(nbk.seq) )

%!test 'normal use'
%! nbk = nbkMatchSettings(20,5,2,[4  5  5 6; 0 0 0 0])

%!test  'respects max/min consc in getSettings.m for continous block'
%! s = getSettings();
%! n = s.events.nPureBlk;
%! nbn = s.nbk.nbnum;
%! pn = s.nbk.pureBlkNprobe;
%! consProbeMax= s.nbk.maxConsProbe;
%! consProbeMin= s.nbk.minConsProbe;
%! for i=1:25
%!  nbk = nbkMatchSettings(n,pn,nbn,[]);
%!  seq=nbk.seq; isprobe=nbk.bool; seqi=nbk.seqi; 
%!  consProbes = nnz( find( diff(find(isprobe))==1) );
%!  %pp = find(isprobe),
%!  %diffs = diff(find(isprobe)),
%!  %consProbes,
%!  assert( consProbes >= consProbeMin)
%!  assert( consProbes <= consProbeMax)
%! end


