% n-Back Multi-Source Interference
%
% block type is 1 (nback) 2 (interf) or 3 (mixed)
function nBMSI(subj,blocktype,varargin)
 % block type should be a number
 if ischar(blocktype), blocktype=str2num(blocktype), end


 s = getSettings('init',varargin{:});
 [e, emat] = genEventList(blocktype);
 [savename,dstr] = formatSaveName(subj,blocktype);

 if isfield(emat.inf,'congidx')
   fprintf('cong intference trials on:\n');
   fprintf('\t%d\n', emat.inf.congidx);
 end

 %try
    w=setupScreen(s.screen.bg, s.screen.res);

    instructions(w,blocktype);

    res=cell(1,length(e));
    starttime= GetSecs();
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

 closedown()

end
