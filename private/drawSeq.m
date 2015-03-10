function t=drawSeq(w,when,seq,varargin)
  colors=getSettings('colors');
  
  % join cell with spaces
  dispseq=strjoin(seq,'  ');
  oldFontSize=Screen(w,'TextSize',colors.seqtextsize);
  DrawFormattedText(w,dispseq,'center','center',colors.seqtext);
  Screen(w,'TextSize',oldFontSize);
  [v, t.onset ] = Screen('Flip',w,when,varargin{:});
end
