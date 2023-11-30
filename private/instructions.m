%
% go through the instructions
%  instructions are longer if bn is negative
%  or varargin contains 'practice'
%
% instructions are a cell of strings,function_handles, and image file paths
% each cell element is a new slide
%
function instructions(w,bn,varargin)

    taskdir=pwd;
    overview_image = 'img/overview.png';
    if bn>=10,
       overview_image = 'img/instruct_cog_inf_only.png';
    end
    
    %% should we go through the practice slides?
    practice=getSettings('pracsett');

    % make blocks 1-4 instead of -9 to +9
    bn=abs(bn);
    if bn>4; bn=4; end

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
     {  ['This time we will test your memory with the BLUE cross'] ...   
        ['When the screen of numbers comes up after a BLUE cross,\n\n push the button that matches the different number.\n\n' ...
           'AND\n\n\n'...
           'you should also remember the number that was different!'] ...
           ['Sometimes after a blue cross, "XXX" will appear instead of numbers.\n\n' ...
           'When this happens, recall the number you remembered 2 times ago \n\n'...
           'and press the button matching that number! \n\n '],...
           ['img/nback.png']...
     }, ...
     ... block num 2 = inf = red
     {   ['This time, we are going to try to trick you with the RED cross.'], ...
         ['When the screen of numbers comes up after a RED cross,\n\n you will still push the button matching the different number. \n\n',...
          'But, make sure you are pushing the button matching the different number, NOT the location on the screen!'], ...
         ['img/interf.png'], ...
     }, ...
      ... block num 3 = cong = green 
     {  ['First, you will practice the green cross trials '] ...
        ['Here, when the screen of numbers comes up after a GREEN cross,\n\n' ...
        'push the button that matches the different number.'], ...
        ['img/congr.png'], ...
     } ...
      ... block num 4 = mix = switch = blue/red/green 
      overview_image
    };

    if practice.ispractice
       instruct = [...
         instruct ,{...
         'img/fingers.png', ...
         'Before each set of numbers, there will be either a green, red, or blue cross.\n\n'...
         },...
         blockspecificinstruct{bn} ...
      ];
    else
      % add the overview screen
      instruct = [ instruct, {overview_image} ];
    end 



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
