%
% go through the instructions
%  instructions are longer if bn is negative
%  or varargin contains 'example'
%
% instructions are a cell of strings,function_handles, and image file paths
% each cell element is a new slide
%
function instructions(w,bn,varargin)

    taskdir=pwd;
    
    %% should we go threw the examples?
    % yes if
    %   it's pracitce (block less than 1)
    %   or if we ask (with 'example')
    % 
    useexample=any(cellfun(@(x) ~isempty(strmatch(x,'example','exact')), varargin));

    % negative numbers imply example
    if(bn<1)
     useexample=1;
    end
    bn=abs(bn);

    % hard coded :(
    %keys=getSettings('keys');

    colors=getSettings('colors');

    
    % always start with same instructions
    instruct = {...
    [ ...
      'In this game, you will see sets of 3 numbers.\n\n',...
      'One of the numbers will be different.\n\n',...
      'Always push the button for the DIFFERENT number.'...
    ]};

    blockspecificinstruct={ ...
     ... block num 1 = nback = blue
     {     ['If the cross is BLUE,\n\n push the button that matches the different number.\n\n' ...
           'AND\n\n\n'...
           'you should also remember the number that was different!\n\n'...
           'Sometimes after a blue cross, "XXX" will appear instead of numbers.\n\n' ...
           'When this happens, recall the number you remembered 2 times ago \n\n and press the button matching that number! \n\n ']...
     }, ...
     ... block num 2 = inf = red
     {   ['If the cross is RED,\n\n you will still push the button matching the different number. \n\n',...
          'But, make sure you are pushing the button matching the different number, NOT the location on the screen!'], ...
         ['img/interf.png'], ...
     }, ...
      ... block num 3 = cong = green 
     {  ['If the cross is GREEN,\n\n push the button that matches the different number.'], ...
        ['img/congr.png'], ...
     } ...
    };

    if useexample
       instruct = [...
         instruct ,{...
         ... [ ...
         ...   'Your index finger is number 1.\n\n'...
         ...   'Your middle finger is number 2.\n\n'...
         ...   'And your ring finger is number 3.'
         ... ],...
         'img/fingers.png', ...
         'Before each set of numbers, there will be either a green, red, or blue cross.\n\n'...
         },...
         blockspecificinstruct{bn} ...
      ];
    end 

    % add the overview screen
    instruct = [ instruct, {'img/overview.png'} ];


 %%% actual function

    KbCheck;
    for i = 1:length(instruct)
      curinst = instruct{i};
      switch class(curinst)
        case 'char'
          if exist([taskdir '/' curinst],'file')
           [img map alph] = imread([taskdir '/' curinst]);
           img(:,:,4)=alph;
           tex = Screen('MakeTexture', w,img);
           Screen('DrawTexture', w, tex,[],[],0);

          % just show the text
          else
             % add newlines for windows
             if ispc
              % instruct{i}=strrep('\n','\n\n');
             end
             DrawFormattedText(w,curinst,'center','center',[ 0 0 0 ]);
          end
        case 'function_handle'
          warning('don''t yet know what to do with functions')
          curinst(w);

        otherwise
          error('bad instructions!')
      end

      Screen('Flip',w);
      WaitSecs(.5);

      [secs, keyCode, deltaSecs] =KbWait;
      escclose(keyCode);
    end
end

function DrawSeqText(w,seq,colors)
  oldFontSize=Screen(w,'TextSize',colors.seqtextsize);
  DrawFormattedText(w,seq,'center','center',colors.seqtext),...
  Screen(w,'TextSize',oldFontSize);
end
