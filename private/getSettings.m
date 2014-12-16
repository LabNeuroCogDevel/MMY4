function setting=getSettings(varargin)
  persistent s;
  if isempty(s)
     s.screen.res=[800 600];
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
                      'd','f'};


    % color for number sequences
    s.colors.seqtext       = [0   0   0  ];
    s.colors.iticross      = [0   0   0  ];
    s.colors.Fix.Nback     = [0   0   255];
    s.colors.Fix.Interfere = [255 0   0  ];
    s.colors.bg            = s.screen.bg;


    % event settings
    s.events.nTrl = 120;
    s.nbnum=1; % n of the n-back

    s.time.Nback.wait=1;
    s.time.Nback.fix=1;

    s.time.Interfere.wait=1;
    s.time.Interfere.fix=1;

    s.time.ITI.max=Inf;
    s.time.ITI.min=1;
  end

  %% return only what we ask for
  %  or return all settings if nothign specified
  if(length(varargin)==1)
    setting=s.(varargin{1});
  else
    setting=s;
  end
end
