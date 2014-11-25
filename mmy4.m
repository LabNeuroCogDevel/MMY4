function mmy4(subj,cb,varargin)


 s = getSettings(varargin{:});
 e = genEventList(s.events.nTrl);

 %try
    w=setupScreen(s.screen.bg, s.screen.res);

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
