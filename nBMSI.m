function nBMSI(subj,blocktype,varargin)
%% NBMSI - n-Back Multi-Source Interference
%%
%% USAGE: nBMSI(subj,blocktype)
%%   or   nBMSI subj blocktype
%% EXAMPLE:
%%
%%  nBMSI 12345 congr
%%  nBMSI 12345 nback practice % run nback, show extended instructions
%%  nBMSI 12345 -1             % same as above
%%  nBMSI 12345 congr practice Admin_PC % force MR computer, show more instructions
%%
%% block type can be given as a string or number
%%   1 - nback,nb, blue;
%%   2 - interference, int, red;
%%   3 - congruent, cong, green;
%%   4 - mix (mix1,mix2,mix3,mix4);
%%  10 - in/cog{1,2,3,4}: no nback. cog and incog only
%%  20 - longmix{1,2}; no nback. longer
%%  see private/blockName2Num.m and private/genEventList.m
%%
%% negative numbers are practice of the positive number (imply 'practice')
%%  - practice has sounds
%%  - will stop early if accuracy is good
%%
%% output is saved in behave/subj_block_time.mat and behave/csv/subj_block_time

 if(nargin < 1)
    help('nBMSI');
    error('USAGE: nBMSI subjid in/cog1 practice');
 end

 origblockname=blocktype;
 % block type should be a number
 blocktype = blockName2Num(blocktype);
 %if ischar(blocktype), blocktype=str2double(blocktype);  end

 % subject should be a string
 if isfloat(subj), subj=num2str(subj);  end

 [savename,dstr] = formatSaveName(subj,blocktype);
 diary([savename '_log.txt']);

 % make sure we set practice when we give a negative block number
 if blocktype < 1; varargin = {varargin{:}, 'practice'}; end
 % get settings
 s = getSettings('init',varargin{:});

 %20150123 - WF+SM@MRRC
 %  cd to private b/c genEvent depends on functions in that directory
 %  ML2011a (MR version):  private/function.m does not have access to other functions in private/
 isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
 if(~isOctave)
     cd private
 else
     addpath('private'); pkg('load','statistics')
 end
 % if genEventList failes on matlab 2011 after we cd'ed
 % we'll be in private and clueless as to why cmd from history doesn't run
 try
    [e, emat] = genEventList(blocktype);
 catch genfailed
     if(~isOctave), cd ..; end
     error(genfailed)
 end

 % 20240306 - useful to have esp. at scan time
 expect_total_dur = e(end).onset + e(end).duration + s.time.ITI.end;
 fprintf('++ expect total duration: %.2f ++\n', expect_total_dur);

 if(~isOctave);cd ..;end


 if isfield(emat.inf,'congidx')
   fprintf('cong intference trials on:\n');
   fprintf('\t%d\n', emat.inf.congidx);
 end

 %try
    w=setupScreen(s.screen.bg, s.screen.res);

    instructions(w,blocktype,varargin{:});


    % we start when the scanner sends the go ahead
    starttime = getReady(w,s.host.type);

    res=cell(1,length(e));
    for ei=1:length(e)

      trl    = e(ei).trl;
      ename  = e(ei).name;
      onset  = e(ei).onset + starttime;
      efunc  = e(ei).func;
      params = e(ei).params;

      fprintf('%d %s %s @ %.3f for %.2f\n',...
              trl, e(ei).tt, ename,e(ei).onset, e(ei).duration);

      res{ei}= efunc(w,onset,params{:});

      % include other useful info
      res{ei}.trl=trl;
      res{ei}.tt=e(ei).tt;
      res{ei}.name=ename;
      res{ei}.idealonset=onset;

      save([savename '.mat'],'res','subj','blocktype', 'e', 'emat', 'savename','dstr','s');

      %% special logic for responsies during practice
      if s.pracsett.ispractice && isfield(res{ei},'seqCrct')
        % play noise if we're wrong/too slow
        playSound(1,res{ei}.seqCrct);

        % end practice early if they're doing well
        if practiceEndEarly(res(1:ei),abs(blocktype))
         break
        end

      end

    end


    % draw final fixation for s.endITI seconds
    % then say good job
    lastonset = event_Fix(w,GetSecs(), s.colors.iticross,s.colors.pd.ITI,255);
    lastonset = lastonset.onset;
    endtime=lastonset+s.time.ITI.end;

    save([savename '.mat'],'res','subj','blocktype', 'e', 'emat', 'savename','dstr','s', 'endtime','lastonset','starttime','endtime','origblockname');

    fprintf('xx END ITI @ %0.3f. On for %0.2f\n',lastonset-starttime, s.time.ITI.end);
    fprintf('xx GOOD JOB will be @ %0.3f\n',endtime-starttime);
    fprintf('   expected duration  %0.3f\n', expect_total_dur);
    goodJob(w,endtime);

    % save output to csv file
    beh=behave([savename '.mat'],[savename '.csv']);

    behaveStats(beh);

    % check for bad timing
    anyMissedOnsets(res);

    % try to save some files
    copyFiles(subj,dstr(1:8),savename)

    % shut it all down
    closedown();

 %catch
 %  closedown()
 %end


end
