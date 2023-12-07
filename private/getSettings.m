% hard coded settings like color screen size, response keys
% * we use the first intput argument as 'init'
%   to say we want to change or re-initialize the settings
% * we can use 'pratice' to set the practice flag
%
function setting=getSettings(varargin)
  persistent s;

  % initialze flags we can get
  opts=struct('init',0,'practice',0);

  % find those flags in the input argument list
  for of=fieldnames(opts)'
   % finish if no args on input
   if isempty(varargin); break; end
   % fieldnames doesn't return exactly what we want
   of=of{1};
   % where is this option in the input arguments
   idxs= cellfun(@(x) ischar(x)&&~isempty(strmatch(x,of,'exact')), varargin);
   % if option exists, set it as true in option list
   opts.(of) = any(idxs);
   % clear varargin of the option
   varargin(idxs) = [];
  end

  
  % if we haven't defined s
  % or if we say 'init'
  % (re)define s
  if isempty(s) || opts.init

     %% get host name and set info related to it
     %% we can also specify a host name as an option
     if isempty(varargin) 
        [returned,host] = system('hostname');
        host=strtrim(host);
        host(host=='-')='_';
        fprintf('# settings from hostname "%s"\n', host)
     else
        host = varargin{1};
        fprintf('# forcing host to "%s"\n', host)
     end 

     % behave true => fixed .5sec ITI
     % MR          => show getready screen
     % MEG         => send trigger codes and photodiode
     s.host.name = host;
     
     if strncmp(host,'Admin_PC',8) ||...   % MRCTR
        strncmp(host,'MRRCNewwin7_PC',15)  % BST3 7T
      s.host.type='MR';
      s.host.isMR=1;
      s.host.isBehave=0;
      s.host.isMEG=0;
      s.screen.res=[1024 768];   
      fprintf('# running MR\n');
      
     elseif strncmp(host,'PUH1DMEG03',5) %MEG
      s.host.type='MEG';
      s.host.isMR=0;
      s.host.isBehave=1;
      s.host.isMEG=1;
      s.screen.res=[1280 1024];
      fprintf('# running MEG\n');

      
     % MR Practice comp/lab behavioral
     elseif strncmp(host,'upmc_56ce704785',15) || ...
            strncmp(host,'OACWIN71LOEFF88',15)
      s.host.type='Behave';
      s.host.isMR=0;
      s.host.isBehave=1;
      s.host.isMEG=0;
      s.screen.res=[1440 900];
      fprintf('# running known behave\n');
      
     else
      s.host.type='Unknown';
      s.host.isMR=0;
      s.host.isBehave=1;
      s.host.isMEG=0;
      s.screen.res=[1024 768];
      fprintf('# running behave for unknown host "%s"\n', host);
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
     if s.host.isMR || s.host.isMEG
       % Button Glove index: middle, ring
       fprintf('# Using buttonbox keys\n');
       s.keys.names = {'2@','3#','4$'};
     else
       fprintf('# Using keyboard keys\n');
       %s.keys.finger = KbName({'j','k','l'}); % TESTING
       s.keys.names = {'LeftArrow','DownArrow','RightArrow'};
     end
     s.keys.finger = KbName(s.keys.names);
     
     % string corresponding to finger
     % MUST BE numeric
     s.keys.string = {'1','2','3'};

     s.keys.fingernames = {...
                      'right index finger',...
                      'right middle finger',...
                      'right ring finger', ...
                      };


    % color for number sequences
    s.colors.seqtext       = [0   0   0  ];
    s.colors.iticross      = [255 255 255];
    s.colors.Fix.Nback     = [42  155 220];%[0   0   155];
    s.colors.Fix.Interfere = [245 93  133];%[155 0   0  ];
    s.colors.Fix.Congruent = [23  168  87];%[0   155 0  ];
    % http://vis4.net/labs/colorvis/embed.html?m=hcl&gradients=12
    % L=1.53
    s.colors.bg            = s.screen.bg;
    % not actually a color, but is needed when color is needed
    s.colors.seqtextsize   = 40;


    %% photo diode intensities
    s.colors.pd.cue = 1;
    s.colors.pd.seq = 0;
    s.colors.pd.RT  = 0.66;
    s.colors.pd.ITI = 0.33;

    % event settings
    s.events.nTrl    = 60; % number trials
    s.events.nTrlNoNbk=40; % no nback? 2*20 for just cog and incog
    s.events.nPureBlk= 35; % number of trials for not mix blocks
    s.events.nInfPureCng=4;% number of trials that will be congruent
                           %   in the pure inteference block

    s.events.nminblocks=12;% number of miniblocks
                           % nSwitches = nminblocks -1
    s.events.nminblocksNoNbk=8; % 3*2



    s.nbk.nbnum=2;          % n of the n-back
    s.nbk.nprobe=5;         % how many probes 
    s.nbk.pureBlkNprobe= ceil(s.events.nPureBlk/4); % how many probes for single block, 25%
    s.nbk.minConsProbe=  1; % least amount of consecutive probes
    s.nbk.maxConsProbe=  1; % most amount of consecutive probes
    % cons probe fixed at 2, changed to 1 (no repeats) 20150309


    %% explictly set number of nback
    %  with input arguments
    nbidx = find(  cellfun(...
               @(x) ischar(x)&&strcmpi(x,'nbnum'), varargin ...
         ))+1;

    if opts.init && ~isempty(nbidx)
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


   %% practice options, cannot be called practice b/c
   %   if we call getSettings('practice') it will be stripped out
   s.pracsett.ispractice = opts.practice;
   % how many in a row need to be correct
   s.pracsett.nbk  = 3;
   s.pracsett.intf = 3;
   s.pracsett.cong = 3;
   s.pracsett.mix  = 5;
   % what is the percent correct needed to end the trial early
   % s.pracsett.mincorper = .9; %20150513 -- just use the windows above

   % if we are practicing, we want to open the sound handle
   % before we get into the task and cause huge delays
   if opts.practice
     openPTBSnd();
   end

   % MEG trigger codes: see getTrigger.m

  end

  %% return only what we ask for
  %  or return all settings if nothing specified
  %  also return everything if we specified 'init'
  if length(varargin)==1 && ~ opts.init
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
