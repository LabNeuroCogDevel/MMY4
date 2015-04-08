% draw a border for the photo diode
function drawPhDioBox(w,intensity,varargin)
 % get weither or not we should use MEG
 persistent isMEG;
 if isempty(isMEG)
   h=getSettings('host');
   isMEG=h.isMEG;
 end

 if ~isMEG
  return
 end
 
 screen=Screen('Rect',w);
 
 % default width
 width=100;
 if(~isempty(varargin)); width=varargin{1}; end
 
 
 rectangles = [ ...
     % only need one cornor
     %[screen(3)-width  0               screen(3)  width    ]; ... TR
     [0                0               width      width    ]; ... TL
     %[0                screen(4)-width width     screen(4) ]; ... BL
     %[       screen(3:4)-width             screen(3:4)     ]; ... BR
  ];
 
 Screen('FillRect', w, ones(3,1).*255*intensity, shiftdim(rectangles,1) );


end

