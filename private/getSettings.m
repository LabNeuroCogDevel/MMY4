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
     
     %s.screen.res=[800 600];   % any computer, testing
     %s.screen.res=[1600 1200]; % will's computer
     %s.screen.res=[1280 1024]; % test computer in Loeff
     s.screen.res=[1024 768];   % MRCTR
     s.screen.bg=[120 120 120];

     KbName('UnifyKeyNames')

     %                   notback isback -- 201501 -- no more nback keypush
     %s.keys.nback  = KbName({'d','f'});
     
     
     %                  index  middle ring
     %s.keys.finger = KbName({'j','k','l'}); % TESTING
     s.keys.finger = KbName({'2@','3#','4$'}); % ACTUAL
     
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
    s.events.nTrl    = 60;% number trials
    s.events.nPureBlk=40;  % number of trials for not mix blocks
    s.events.nInfPureCng=4;% number of trials that will be congruent in the pure inteference block

    s.events.nminblocks=12;% number of miniblocks
                           % nSwitches = nminblocks -1



    s.nbk.nbnum=2;          % n of the n-back
    s.nbk.nprobe=5;         % how many probes 
    s.nbk.pureBlkNprobe=12; % how many probes for single block
    s.nbk.minConsProbe=  2; % least amount of consecutive probes
    s.nbk.maxConsProbe=  2; % most amount of consecutive probes


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
