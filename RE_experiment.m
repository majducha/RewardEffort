%% Reward/Effort trade-off experiment
% I this experiment participant is shown 2 options with different level of 
% reward and effort. He then have to choose one option according to his
% preference and perform the effortful task (clicking on targets).

%% Clear the screen and workspace
sca;
close all;
clearvars;

%% Open and set-up Psychotoolbox

%Skip synctest and hide the error message - used as I have a laptop and
%not a separate screen

Screen('Preference', 'SkipSyncTests', 2);
Screen('Preference', 'VisualDebugLevel', 0);

% Defaults for PTB - check that Screen() is functional, unifies colour and
% key codes across different OS.

PsychDefaultSetup(2); 

%Gets Id for the screen
screen = Screen('Screens');

%% Set-up

%pathway


% Schedule input
load('RE_input.mat'); %columns: Reward Left, Reward Right, Effort Left, Effort Right 

% Extracts max possible reward and effort from the input file
max_Reward = max([max(RE_input(:,1)),max(RE_input(:,2))]); 
max_Effort =  max([max(RE_input(:,3)),max(RE_input(:,4))]); 

% Calculate percent maximum reward/effort
pre(:,1:2) = RE_input(:,1:2)/max_Reward;
pre(:,3:4) = RE_input(:,3:4)/max_Effort;

% Keyboard names
KeyL=KbName('LeftArrow'); 
KeyR=KbName('RightArrow');
KeyS = KbName('space');
KeyESC = KbName('ESCAPE');

% Scanlist - create list of keys to monitor/ignore
scanlist = NaN(256,2);
for ikey = 1:length(KbName('KeyNames'))
    if ikey == KeyL || ikey == KeyR || ikey == KeyS || ikey== KeyESC
        scanlist(ikey,2) = 1;
    else
        scanlist (ikey,2) = 0;
    end
end

% Colours
black = [0 0 0];
Bg_colour = [127 127 127]; % background in gray
Ef_colour = [200 20 30]; % effort in red
R_colour = [20 200 30]; % reward in green
C_colour = [256 256 256]; % choice highlight 

%set up target and jitter size
circle = 30;
jitter = 40;

%% OUTPUT variables (pre-allocation)

% response - records participants response
response = NaN(length(RE_input),1); 

% reward- records winnings at each trial
reward = NaN(length(RE_input),1); 

% effort - records effort taken at each trial
effort = NaN(length(RE_input),1); 

% DT - records how much time it took to decide on an option
DT = NaN(length(RE_input),1);

% RT - records how much time it took to click all targets
RT = NaN(length(RE_input),1);

%% EXPERIMENT

%% Login prompt

% Fields
prompt = {'Subject ID'};

% default answers
defaults = {'99'}; 

% opens a window asking for prompts
answer = inputdlg(prompt,'RE_intro', 1, defaults); 

%saves the answer(subID) into a variable subid
subid = deal(answer{:});  

% Generate an output name based on the subID
outputname = ['RE_s' subid]; 

%% Open PTB window  

% Open an full screen window  color it grey.
[mainwin,  screenrect] = Screen('OpenWindow',screen, Bg_colour);

% save the size of the window
horW = screenrect(3);  
vertW = screenrect(4);

% get useful window co-ordinates

% middle of the window
[xc, yc] = RectCenter(screenrect); 

% 1/8th of the window length and width
x8 = xc/4;
y8 = yc/4;

%Hide cursor for the duration of the experiment
HideCursor(mainwin)

% Give this experiment priority in the OS processing
topPriorityLevel = MaxPriority(mainwin);
Priority(1); %Only 1 recommended for windows

%% Welcome Screen

% Message: Press any key to start, centered on the screen
DrawFormattedText (mainwin, 'Press any key to start','center','center',black);

% Flip for the message to show up on the mainwin screen
Screen(mainwin, 'Flip');

% wait for any keypress to continue
KbStrokeWait; 

%% Experiment loop

for itrial = 1:length(RE_input)

%% Fixation cross

% Draw fixation cross (40 px) in the middle of the screen
Screen('DrawLine', mainwin, black, xc - 20, yc, xc + 20, yc, 5); 
Screen('DrawLine', mainwin, black, xc, yc- 20, xc, yc + 20, 5);  

Screen('Flip', mainwin, 0, 0);

% Leave the cross on for 2 seconds
WaitSecs(2);

%% Choice Phase - Presentation

% Draw a dividing line between left and right options
Screen('DrawLine', mainwin, black, xc, 0, xc, vertW, 5);

% Plot 4 rectangles representing L/R reward & effort 
rect = [x8, y8, xc-x8, yc-y8; x8, yc+y8,xc-x8, 2*yc-y8; xc+x8, y8, 2*xc-x8, yc-y8; xc+x8, yc+y8,2*xc-x8, 2*yc-y8]';
Screen('FrameRect', mainwin , black , rect, 5);

% Draw ticks in 1/3rd and 2/3rd of the rectangles
t = 2*x8/3;

Screen('DrawLines',mainwin,[x8+ [t,t,t,t,2*t,2*t,2*t,2*t]; -y8 + [yc-20, yc, 2*yc-20,2*yc,yc-20, yc, 2*yc-20,2*yc]],5, black);
Screen('DrawLines',mainwin,[xc+x8 + [t,t,t,t,2*t,2*t,2*t,2*t]; -y8 + [yc-20, yc, 2*yc-20,2*yc,yc-20, yc, 2*yc-20,2*yc]],5, black);

% Plot reward for the left option
%Screen('FrameRect', mainwin , black , [x8, y8, xc-x8, yc-y8], 5);
Screen('DrawLine', mainwin, R_colour, x8+2*x8*pre(itrial,1), y8, x8 + 2*x8*pre(itrial,1), yc-y8, 5); 

%Plot effort for the left option
%Screen('FrameRect', mainwin , black , [x8, yc+y8,xc-x8, 2*yc-y8], 5);
Screen('DrawLine', mainwin, Ef_colour, x8+2*x8*pre(itrial,3), yc+y8, x8 + 2*x8*pre(itrial,3),  2*yc-y8  , 5); 

%Plot reward for the right option
%Screen('FrameRect', mainwin , black , [xc+x8, y8, 2*xc-x8, yc-y8], 5);
Screen('DrawLine', mainwin, R_colour, xc+x8+2*x8*pre(itrial,2), y8,xc+x8+2*x8*pre(itrial,2), yc-y8, 5); 

%Plot effort for the right option
%Screen('FrameRect', mainwin , black , [xc+x8, yc+y8,2*xc-x8, 2*yc-y8], 5);
Screen('DrawLine', mainwin, Ef_colour, xc+x8+2*x8*pre(itrial,4), yc+y8, xc+x8+2*x8*pre(itrial,4), 2*yc-y8, 5); 

% Draw the above and add the following on top of the previous screen
Screen('Flip', mainwin, 0, 1); 

% Wait 1 s to prevent accidental key presses
WaitSecs(0.5); 

% Draw a question mark to indicate that participant might make his choice
Screen('FillOval',mainwin, black, [xc - 50, yc-50, xc + 50, yc+50], 5);
Screen('TextSize', mainwin, 60);
DrawFormattedText (mainwin, '?','center','center', Bg_colour);

% Draw the above, mark that it will eventually be replaced by the next
% screen Draw command - i.e. choice hightlight
Screen('Flip', mainwin, 0, 2) 


HideCursor(mainwin)
%% Choice Phase - Participant's Choice

% start measuring DT time, substract 0.5 as the stimuli was already seen for
% that amount of time before any choice could have been made 

startDT = GetSecs-0.5;

while 1
   % checks if the keys mentioned in scalist are pressed (i.e. left/right arrow, space, esc)
    [keyIsDown,secs,keyCode]= KbCheck([], scanlist); 
  
  % if left/right key is pressed, save the response (L=0, R=1), and the
  % effort and reward chosen
  if keyIsDown
     if keyCode(KeyL)
           response(itrial) = 0;
           
           reward(itrial) = RE_input(itrial, 1 + response(itrial));
           effort(itrial) = RE_input(itrial, 3 + response(itrial));
           
           break
      
      elseif keyCode(KeyR)
           
          response(itrial) = 1;
           
           reward(itrial) = RE_input(itrial, 1 + response(itrial));
           effort(itrial) = RE_input(itrial, 3 + response(itrial));
           
           break
 
      %if ESC is pressed, save the outputs and close the window    
      elseif keyCode(KeyESC)
           output = table(response, reward, effort, DT, RT);
           save(outputname,'output');
           
           sca;
           close all;
           break
    
      end
   end
end

DT(itrial,1)= GetSecs-startDT;  

% Highlight participant's choice by frame 20px smaller than half-window
if response(itrial) == 0
    Screen('FrameRect', mainwin , C_colour , [20, 20, xc-20, vertW-20], 5);
elseif response(itrial) == 1
    Screen('FrameRect', mainwin , C_colour , [xc+20, 20, horW-20, vertW-20], 5);
end

Screen('Flip', mainwin, 0, 0)

%Display the choice of 1s
WaitSecs(1);

%% Effort Phase - Target generation
% Generate TargetNum number of targets, so that they have random position
% on the screen.

%Look-up how many targets should appear based on participant's choice
targetNum = effort(itrial,1);

% Generate the left and upper border coordinates
% min value = jitter size, so that the target is always pressable
% maximum value size of the window - circle size - so that the circle can
% be drawn

rng('shuffle')
targetSeed = [randi([jitter, horW-circle], targetNum, 1), randi([jitter,vertW-circle],targetNum, 1)]';

% Generate the remaining coordinates
targetLoc= [targetSeed(1,:); targetSeed(2,:); targetSeed(1,:)+circle; targetSeed(2,:)+circle];

%% Effort-Phase click on the targets
% Participants clicks(space key) on the targets appearing one-by-one on the 
% screen. The cursor has added jitter to increase difficulty of the task.

%Set the initial position of the mouse to be in the centre of the screen
SetMouse(xc, yc, mainwin);

% Measure flip interval of the screen
ifi = Screen('GetFlipInterval', mainwin); 
vbl = Screen('Flip', mainwin);

% sets how often screen will be refreshed (Good for the jitter, if the
% jitter was added with every frame, we would see multiple cursors)
waitframes = 4; 

% Indicates number of  targets that has been clicked on
targetH = 0;

%Measures
start = GetSecs;

% create the mouse/cursor jitter
    while targetH < targetNum
        
        [keyIsDown,secs,keyCode]= KbCheck([], scanlist); 
  
        % Draw the target
        Screen('FrameOval',mainwin, black,targetLoc(:,1+targetH)', 1); %targetLoc || targetLoc(:,1+targetH)'
        
        % Get the current position of the mouse
        [x, y, buttons] = GetMouse(mainwin);
                        
        % Draw a black dot where the mouse cursor is
         xr = x+randi(jitter);
         yr = y+randi(jitter);
            
        Screen('DrawDots', mainwin, [xr yr], 10, [0 0 0], [], 2);    
            
        % Flip to the screen every 4th frame. 0.5 frame duration is 
        %substracted so that there us some headroom to take possible timing
        %jitter or roundoff-errors into account.
            
        vbl= Screen('Flip', mainwin, vbl + (waitframes-0.5) * ifi); 
        
   
% Checks if SPACE was pressed when mouse was inside the target or if ESC
% was pressed
        inside = IsInRect(xr, yr, targetLoc(:,1+targetH)'); 
        if keyIsDown
           if keyCode(KeyS)
               if inside == 1
                  targetH = targetH + 1;
                  Screen('Flip', mainwin)
               end

            elseif keyCode(KeyESC)
                output = table(response, reward, effort, DT, RT);
                save(outputname,'output');
                
                sca;
                close all;
           end
        end
             
         
    end
    
% Saves the RT for the effort phase
RT(itrial,1) = GetSecs - start;


%% Feedback Phase
%{
DrawFormattedText (mainwin, 'Well Done','center','center',black);
Screen(mainwin, 'Flip');
WaitSecs(1)
%}

end
%% Save the OUTPUT variables
% Saves variables response, reward, effort, DT and RT into a .mat file

output = table(response, reward, effort, DT, RT);
save(outputname,'output');

%% Goodbye Screen

% Display the end message + ow much money was earned
Screen('TextSize', mainwin, 30);
DrawFormattedText (mainwin, ['Well Done! You win ' num2str(sum(reward,1)), ' cents'],'center','center',black);
Screen(mainwin, 'Flip');

%  wait for any to terminate the experiemnt
KbStrokeWait;

% Clear the screen.
sca;