function crctKeyIdx = findFingerInSeq(seq,string)
  
  % find which key in the string seq is in the correct position
  crctKeyIdx = find( strcmp( seq, string  )  );

  if length(crctKeyIdx)~=1
     error('seq and strings do not match in exactly one place')
  end

end

%!assert(findFingerInSeq({'1','3','2'},{'1','2','3'}),1 )
%!assert(findFingerInSeq({'3','2','1'},{'1','2','3'}),2 )
%!assert(findFingerInSeq({'2','1','3'},{'1','2','3'}),3 )
%!assert(findFingerInSeq({'3','1','3'},{'1','2','3'}),3 )
%
%!assert(findFingerInSeq({'1','1','1'},{'1','2','3'}),1 )
%!assert(findFingerInSeq({'1','3'},{'1','2'}),1 )
%!assert(findFingerInSeq({'1','0','0'},{'1','2','3'}),1 )
%!assert(findFingerInSeq({'d','a','c'},{'a','b','c'}),3 )
%
%!error findFingerInSeq({'0','1','0'},{'1','2','3'})
%!error findFingerInSeq({'1','2','3'},{'1','2','3'})
%!error findFingerInSeq({'5','6','7'},{'1','2','3'})
