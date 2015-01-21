% hard coded settings like color screen size, response keys
function setting=getSettings(varargin)
  persistent s;

  % we use the first intput argument as 'init'
  % to say we want to change or re-initialize the settings
  isinit=( ~isempty(varargin) && strncmp(varargin{1},'init',4) );
  
  % if we haven't defined s
  % or if we say 'init'
  % (re)define s
  if isempty(s) || isinit
     
     %s.screen.res=[800 600];
     %s.screen.res=[1600 1200];
     s.screen.res=[1280 1024];
     s.screen.bg=[120 120 120];

     KbName('UnifyKeyNames')

     %                   notback isback
     s.keys.nback  = KbName({'d','f'});
     %                  index  middle ring
     s.keys.finger = KbName({'j','k','l'});
     
     % string corresponding to finger
     % MUST BE numeric
     s.keys.string = {'1','2','3'};

     s.keys.fingernames = {...
                      'right index finger(j)',...
                      'right middle finger(k)',...
                      'right ring finger(l)', ...
                      };


    % color for number sequences
    s.colors.seqtext       = [0   0   0  ];
    s.colors.iticross      = [255 255 255];
    s.colors.Fix.Nback     = [0   0   155];
    s.colors.Fix.Interfere = [155 0   0  ];
    s.colors.Fix.Congruent = [0   155 0  ];
    s.colors.bg            = s.screen.bg;


    % event settings
    s.events.nTrl = 120;   % number trials
    s.events.nPureBlk=40;  % number of trials for not mix blocks
    s.events.nInfPureCng=4;% number of trials that will be congruent in the pure inteference block

    s.events.nminblocks=24;% number of miniblocks
                           % nSwitches = nminblocks -1



    s.nbk.nbnum=2;          % n of the n-back
    s.nbk.nprobe=12;        % how many probes 
    s.nbk.pureBlkNprobe=12; % how many probes for single block


   nbidx = find(  cellfun(...
               @(x) ischar(x)&&strcmpi(x,'nbnum'), varargin ...
         ))+1;
    if isinit && ~isempty(nbidx)
      s.nbk.nbnum=varargin{nbidx};
    end

    s.time.Nback.wait=1.5;
    s.time.Nback.cue=1;

    s.time.Interfere.wait=1.5;
    s.time.Interfere.cue=1;

    s.time.Congruent.wait=1.5;
    s.time.Congruent.cue=1;

    s.time.ITI.max=Inf;
    s.time.ITI.min=1;
  end

  %% return only what we ask for
  %  or return all settings if nothing specified
  %  also return everything if we specified 'init'
  if length(varargin)==1 && ~ isinit
    setting=s.(varargin{1});
  else
    setting=s;
  end
end

%!test  % setting nbnum
%! s=getSettings('init','nbnum',3);
%! assert(s.nbk.nbnum==3)
%! nbk=getSettings('nbk');
%! assert(nbk.nbnum==3)
