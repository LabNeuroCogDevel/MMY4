% n-Back Multi-Source Interference
%
% USAGE: nBMSI(subj,blocktype) 
%   or   nBMSI subj blocktype
% EXAMPLE:
%
%  nBMSI 12345 1
%
% block type is 1 (nback) 2 (interf) 3 (cong) or 4 and greater (mixed)
% negative numbers are practice of the positive number
%
% output is saved in behave/subj_block_time.mat and behave/csv/subj_block_time
function nBMSI(subj,blocktype,varargin)
 % block type should be a number
 % subject should be a string
 if ischar(blocktype), blocktype=str2double(blocktype);  end
 if isfloat(subj), subj=num2str(subj);  end
 
 [savename,dstr] = formatSaveName(subj,blocktype);
 diary([savename '_log.txt']);
 
 % get settings
 s = getSettings('init',varargin{:});
 
 %20150123 - WF+SM@MRRC 
 %  cd to private b/c genEvent depends on functions in that directory 
 %  ML2011a (MR version):  private/function.m does not have access to other functions in private/
 sOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
 if(~sOctave);cd private;end
 [e, emat] = genEventList(blocktype);
 if(~sOctave);cd ..;end
 

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

      fprintf('%d %s %s @ %.3f for %.2f\n',trl, e(ei).tt, ename,e(ei).onset, e(ei).duration);
      res{ei}= efunc(w,onset,params{:});
      % include other useful info
      res{ei}.trl=trl;
      res{ei}.tt=e(ei).tt;
      res{ei}.name=ename;
      res{ei}.idealonset=onset;
      save([savename '.mat'],'res','subj','blocktype', 'e', 'emat', 'savename','dstr','s');

    end
    

    
    % draw final fixation for s.endITI seconds
    % then say good job
    lastonset = event_Fix(w,GetSecs(), s.colors.iticross);
    lastonset = lastonset.onset;
    endtime=lastonset+s.time.ITI.end;

    save([savename '.mat'],'res','subj','blocktype', 'e', 'emat', 'savename','dstr','s', 'endtime','lastonset');

    fprintf('xx END ITI @ %0.3f for %0.2f\n',lastonset-starttime, s.time.ITI.end);
    fprintf('xx GOOD JOB @ %0.3f\n',endtime-starttime);
    goodJob(w,endtime);

    % save output to csv file
    beh=behave([savename '.mat'],[savename '.csv']);

    behaveStats(beh);
    copyFiles(subj,dstr(1:8),savename)

    % shut it all down
    closedown();

 %catch
 %  closedown()
 %end


end
