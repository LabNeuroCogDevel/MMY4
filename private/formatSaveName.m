% formatSaveName(<subj>,<block>,...)
% make a name with variable inputs like:
%  1/1_2_YYYYMMDDHHmm where 1 and 2 are the inputs to the funtion
%  also return date string YYYYMMDDHHmm 
function [savename,dstr] = formatSaveName(varargin)
 outdir='behave/';
 mkdir(outdir);

 % first input should be subject id (esp. if we have more than one input)
 % make subject a directory
 if length(varargin)>1
   outdir=[ outdir varargin{1} '/' ]
   mkdir(outdir)
 end

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
 dstr = [ num2str(d(1)) sprintf('%02d',d(2:5)) ];

 savename=[outdir name '_' dstr ];
end
