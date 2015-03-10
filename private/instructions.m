%
% go through the instructions
%  instructions are longer if bn is negative
%  or varargin contains 'example'
%
% instructions are a cell of strings,function_handles, and image file paths
% each cell element is a new slide
%
function instructions(w,bn,varargin)
    
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
      'In this game, you will see three numbers.\n\n',...
      'One of the numbers will be different.\n\n',...
      'always push the button for the DIFFERENT number.'...
    ]};
    
    if useexample
       instruct = [...
         instruct ,{...
         ... [ ...
         ...   'Your index finger is button 1.\n\n'...
         ...   'Your middle finger is button 2.\n\n'...
         ...   'And your ring finger is button 3.'
         ... ],...
         'img/fingers.png', ...
         'Before each set of numbers, there will be a colored cross.\n\nHere is a full example.', ...
         @(w) drawCross(w,colors.Fix.Congruent ), ...
         @(w) DrawSeqText(w,'1 0 0',colors), ...
         'If the cross is GREEN,\n\n the different number and finger to push will be in the same place.', ...
         'img/congr.png', ...
         'If the cross is RED,\n\n the different number and finger to push will NOT be in the same place.', ...
         'img/interf.png', ...
         [ 'If the cross is BLUE,\n\n the different number and finger to push will be in the same place. like GREEN.\n\n' ...
           'AND\n\n\n'...
           'you should also remember the button you pushed\n\n'...
           'Sometimes "XXX" will appear instead of numbers.\n\n' ...
           'You should then push the button you pushed TWO times ago\n\n'...
         ]...
      }];
    end 

    % add the overview screen
    instruct = [ instruct, {'img/overview.png'} ];


 %%% actual function

    KbCheck;
    for i = 1:length(instruct)
      curinst = instruct{i};
      switch class(curinst)
        case 'char'
          if exist(curinst,'file')
           [img map alph] = imread(curinst);
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
