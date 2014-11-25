function t=drawSeq(w,when,seq)
  colors=getSettings('colors');
  
  % join cell with spaces
  dispseq=strjoin(seq,'  ');

  DrawFormattedText(w,dispseq,'center','center',colors.seqtext);
  [v, t.onset ] = Screen('Flip',w,when);
end
