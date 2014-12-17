% n-Back Multi-Source Interference
%
% block type is 1 (nback) 2 (interf) or 3 (mixed)
function nBMSI(subj,blocktype,varargin)
 % block type should be a number
 if ischar(blocktype), blocktype=str2num(blocktype), end


 s = getSettings('init',varargin{:});
 e = genEventList(blocktype);
 savename = formatSaveName(subj,blocktype);


 %try
    w=setupScreen(s.screen.bg, s.screen.res);

    %instructions(w);

    res=cell(1,length(e));
    starttime= GetSecs();
    for ei=1:length(e)

      trl    = e(ei).trl;
      ename  = e(ei).name;
      onset  = e(ei).onset + starttime;
      efunc  = e(ei).func;
      params = e(ei).params;

      fprintf('%d %s @ %.3f\n',trl,ename,e(ei).onset);
      res{ei}= efunc(w,onset,params{:});
      % include other useful info
      res{ei}.trl=trl;
      res{ei}.tt=e(ei).tt;
      res{ei}.name=ename;
      res{ei}.idealonset=onset;
      res{ei}.params=params;
      save([savename '.mat'],'res','subj','blocktype')

    end
    
 %catch
 %  closedown()
 %end

 closedown()

end
