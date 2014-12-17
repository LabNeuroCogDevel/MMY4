function savename = formatSaveName(varargin)
 outdir='behave/';
 mkdir(outdir);
 % build save name from inputs
 % put a _ between each
 name='';
 for i=1:length(varargin)
   s=varargin{i};
   if isa(s,'float')
    s=num2str(s);
   end
   if i<2
     sep='';
   else
     sep='_';
   end
   name=[ name sep s];
 end

 % add date
 d    = datevec(now);
 dstr = [ num2str(d(1)) sprintf('%02d',d(2:5)) ]

 savename=[outdir name '_' dstr ];
end
