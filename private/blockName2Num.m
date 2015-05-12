% blockName2Num('') take a block name and turn it into a number
% 1: nback (nb, blue)
% 2: interference (int,red)
% 3: congruent (cong,green)
% 4-9: mix (mix1,2,3,4,5,6)
% -- will pass through numbers 
%   can come in as num or char
function bn = blockName2Num(blockname)

   if isfloat(blockname)
    nb=blockname;
   end

   switch blockname

     case {'blue','nback','nb'}
       bn=1;

     case {'red','int','interference'}
       bn=2;

     case {'green','cong','congruent','congr'}
       bn=3;

     case {'mix'}
           bn=4;
     
     case {'mix1','mix2','mix3',...
                 'mix4','mix5','mix6'}
       bn=str2double(blockname(4))+3;
       
     otherwise
       bn=str2double(blockname);

   end

   if(bn>9 || bn<-9)
     error('what blockname did you mean?');
   end

end
