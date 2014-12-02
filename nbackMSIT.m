% block type is 1 (nback) 2 (interf) or 3 (mixed)
function nbackMSIT(subj,blocktype,varargin)


 s = getSettings(varargin{:});
 e = genEventList(s.events.nTrl,blocktype);

 %try
    w=setupScreen(s.screen.bg, s.screen.res);

    instructions(w);

    starttime= GetSecs();
    for ei=1:length(e)

      trl    = e(ei).trl;
      ename  = e(ei).name;
      onset  = e(ei).onset + starttime;
      efunc  = e(ei).func;
      params = e(ei).params;

      fprintf('%d %s @ %.3f\n',trl,ename,e(ei).onset);
      res = efunc(w,onset,params{:});

    end
    
 %catch
 %  closedown()
 %end

 closedown()

end
