% write structure to csv file
function writestructCSV(outname,beh)
 % add sequence to the csv
 fid=fopen(outname,'w');
 
 %header
 fns=fieldnames(beh)';
 fprintf(fid,'%s,',fns{1:(end-1)});
 fprintf(fid,'%s\n',fns{end});

 %ugly hack for fprintf
 %there must be a better way
 fmntstr.char='%s';
 fmntstr.double='%f';

 N=length(beh.(fns{1}));
 colcnt=length(fns);
 % go through by row
 for ii=1:N
    % and by column
    for fi=1:colcnt;
      % get the value
      v=beh.(fns{fi})(ii);
      % make sure we actuall have the string value
      if iscell(v)
       v=beh.(fns{fi}){ii};
      end 

      % set the formating type
      fmt=fmntstr.(class(v));
      % if we have a round number, make format digit instead of float
      if isnumeric(v) && round(v) == v
        fmt='%d';
      end
      % write it
      fprintf(fid, fmt, v); 
      % put commas as long as its not the last column 
      if fi ~= colcnt
       fprintf(fid,',');
      end 
    end

    fprintf(fid,'\n');
 end
 fclose(fid);
end
