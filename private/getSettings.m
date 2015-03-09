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

     %% get host name and set info related to it
     %% we can also specify a host name as a (second) option
     %% but it shouldn't be host 'example' -- thats to give examples
     if length(varargin)<2 || strncmp(varargin{2},'example',7)
        [returned,host] = system('hostname');
        host=strtrim(host);
        host(host=='-')='_';
     else 
        host = varargin{2};
     end 

     % behave true => fixed .5sec ITI
     % MR          => show getready screen
     % MEG         => send trigger codes and photodiode
     s.host.name = host;
     if strncmp(host,'Admin_PC',8)
      s.host.type='MR';
      s.host.isMR=1;
      s.host.isBehave=0;
      s.host.isMEG=0;
      s.screen.res=[1024 768];   % MRCTR
      fprintf('running MR\n');
     elseif strncmp(host,'MEGPC',5)
      s.host.type='MEG';
      s.host.isMR=0;
      s.host.isBehave=1;
      s.host.isMEG=1;
      s.screen.res=[1024 768]; 
     elseif strncmp(host,'upmc_56ce704785',15)
      s.host.type='Behave';
      s.host.isMR=0;
      s.host.isBehave=1;
      s.host.isMEG=0;
      s.screen.res=[1440 900];
     else
      s.host.type='Unknown';
      s.host.isMR=0;
      s.host.isBehave=1;
      s.host.isMEG=0;
      s.screen.res=[1024 768];   
     end
     
     fprintf('screen res: %d %d %s\n',s.screen.res,s.host.name);     
     s.info.MLversion= version();
     s.info.PTBversion = PsychtoolboxVersion();
     fprintf('Versions: %s PTB %s\n',s.info.MLversion,s.info.PTBversion);


     
     %s.screen.res=[800 600];   % any computer, testing
     %s.screen.res=[1600 1200]; % will's computer
     %s.screen.res=[1280 1024]; %test computer in Loeff
     %s.screen.bg=[120 120 120];
     s.screen.bg=[170 170 170];

     KbName('UnifyKeyNames')

     % use fingers:  index  middle ring
     if s.host.isMR
       % Button Glove index: middle, ring
       s.keys.finger = KbName({'2@','3#','4$'}); 
     else
       %s.keys.finger = KbName({'j','k','l'}); % TESTING
       s.keys.finger = KbName({'LeftArrow','DownArrow','RightArrow'}); 
     end
     
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
    s.colors.Fix.Nback     = [42  155 220] %[0   0   155];
    s.colors.Fix.Interfere = [245 93  133];%[155 0   0  ];
    s.colors.Fix.Congruent = [23  168  87];%[0   155 0  ];
    s.colors.bg            = s.screen.bg;
    % http://vis4.net/labs/colorvis/embed.html?m=hcl&gradients=12
    % L=1.53


    % event settings
    s.events.nTrl    = 60; % number trials
    s.events.nPureBlk= 35; % number of trials for not mix blocks
    s.events.nInfPureCng=4;% number of trials that will be congruent
                           %   in the pure inteference block

    s.events.nminblocks=12;% number of miniblocks
                           % nSwitches = nminblocks -1



    s.nbk.nbnum=2;          % n of the n-back
    s.nbk.nprobe=5;         % how many probes 
    s.nbk.pureBlkNprobe= ceil(s.events.nPureBlk/4); % how many probes for single block, 25%
    s.nbk.minConsProbe=  1; % least amount of consecutive probes
    s.nbk.maxConsProbe=  1; % most amount of consecutive probes
    % cons probe fixed at 2, changed to 1 (no repeats) 20150309


   nbidx = find(  cellfun(...
               @(x) ischar(x)&&strcmpi(x,'nbnum'), varargin ...
         ))+1;
    if isinit && ~isempty(nbidx)
      s.nbk.nbnum=varargin{nbidx};
    end

    s.time.Nback.wait=1.5;
    s.time.Nback.cue=.5;

    s.time.Interfere.wait=1.3;
    s.time.Interfere.cue=.5;

    s.time.Congruent.wait=1;
    s.time.Congruent.cue=.5;

    s.time.ITI.max=Inf;
    s.time.ITI.min=1;

    % how long to wait at the end of the block
    s.time.ITI.end=12;

    % fixation time should be about equal to task time
    %
    % 2.5 seconds is cue+probe for nback
    % WF20150224 - cue to .5 now 2 sec ITI mu
    % WF20150224 -  pure blocks will be off by .3 secs * 30 (ntrials)
    %               but we add 12 secs of ITI at the end
    %               so efficiency should be okay still ? 
    s.time.ITI.mu = mean([s.time.Nback.wait;
                         s.time.Interfere.wait;
                         s.time.Congruent.wait]) ...
                     + s.time.Nback.cue;

   % for meg and behave, iti can be fixed at .5
   if s.host.isBehave
      s.time.ITI.min= .5;
      s.time.ITI.mu = .5;
      s.time.ITI.end= 0;
   end



   %% Triggers for MEG
   % cue           x = 0 | 1 | 2  || 3 | 4 | 5  (x = block type, +3 if repeat)
   % numbers/probe y = 10| 20| 30 + mod(x,3)    (y = correct key,+3 if probe)  10 11 12 (not probe) | 13 14 15 (probe)
   % Resp          z = 100 + y|200 + y                  (z = correct|incorrect )
   % ITI           255          (end of trial, thought to subj, end of trial is at resp-- help ID noresp)

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
