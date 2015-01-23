% n-Back Multi-Source Interference
%
% USAGE: nBMSI(subj,blocktype) 
%   or   nBMSI subj blocktype
%
% block type is 1 (nback) 2 (interf) 3 (cong) or 4 (mixed)
%
% output is saved in behave/subj_block_time.mat and behave/csv/subj_block_time
function nBMSI(subj,blocktype,varargin)
 % block type should be a number
 if ischar(blocktype), blocktype=str2num(blocktype), end


 s = getSettings('init',varargin{:});
 
 %20150123 - WF+SM@MRRC 
 %  cd to private b/c genEvent depends on functions in that directory 
 %  ML2011a (MR version):  private/function.m does not have access to other functions in private/
 cd private
 [e, emat] = genEventList(blocktype);
 cd ..
 
 [savename,dstr] = formatSaveName(subj,blocktype);

 if isfield(emat.inf,'congidx')
   fprintf('cong intference trials on:\n');
   fprintf('\t%d\n', emat.inf.congidx);
 end

 %try
    w=setupScreen(s.screen.bg, s.screen.res);

    instructions(w,blocktype);


    % we start when the scanner sends the go ahead
    starttime = getReady(w);

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
    
 %catch
 %  closedown()
 %end

 % save output to csv file
 behave([savename '.mat']);
 goodJob(w);
 closedown()

end
