% generate input
%Based on 108 trials (12 x 9-trial-block, each block has one trial of each
%of possible effort/reward combinations)

%Define folder path
FolderPath = fullfile ('C:', 'Users', 'Majda', 'Documents', 'UNI', 'uni_matlab');

% Input stating the  combinations of effort and reward differences, arranged
% so that all possible combinaitions of the differences are equally
% frequent. 1=LOW Difference, 2=MEDIUM Difference, 3=HIGH Difference

E_mod = [1 1+rem(fix([1:107]/3),3)]';
R_mod = [1 1+rem([1:107],3)]';

% Decide which side will have the lower reward/effort (change every 9
% trials)
S_round= [0 rem(fix([1:107]/9),2)]';

%pre-allocate output variables
R_input = NaN(108,1);
E_input = NaN(108,1);

% Use the reward/effort differences to allocate the option's reward/effort 
% for each trial

for itrial = 1:108
  if S_round(itrial) ==0
          side = 1; % lower reward will be on the left
  elseif S_round(itrial) ==1
          side = 2; % lower reward will be on the right
  end
      
 % Select the lower reward at random, calculate the higher reward by adding
 % a random number to the lower reward so that the difference between the
 % lower and higher reward is either LOW[1-3], MEDIUM[4-6] or HIGH[7-9],
 % and the higher reward is no larger than 9c. (THe maximum reward possible
 % for an option)
 
   if R_mod(itrial) == 1
        R_input(itrial,side)= randi([0 8]);
        if R_input(itrial,side)<7
            R_input(itrial,3-side)= R_input(itrial,side) + randi([1 3]);
        elseif R_input(itrial,side)>=7 && R_input(itrial,side)<= 8
            R_input(itrial,3-side)= R_input(itrial,side) + randi([1 2+(7-R_input(itrial,side))]);
        end
        
   elseif R_mod(itrial) == 2
        R_input(itrial,side)= randi([0 5]);
        if R_input(itrial,side)<4
            R_input(itrial,3-side)= R_input(itrial,side) + randi([4 6]);
        elseif R_input(itrial,side)>= 4 && R_input(itrial,side)<= 5
            R_input(itrial,3-side)= R_input(itrial,side) + randi([4 5+(4-R_input(itrial,side))]);
        end
        
   elseif R_mod(itrial) == 3
        R_input(itrial,side)= randi([0 2]);
        R_input(itrial,3-side)=R_input(itrial,side)+randi([7, 9-R_input(itrial,side)]);
   end
   
   % Repeat for effort. The difference ranges are LOW[1,4], MED[5,8], HIGH
   % [9 12], Maximum effort is 12.
   if E_mod(itrial) == 1
        E_input(itrial,side)= randi([0 11]);
        if E_input(itrial,side)<9
            E_input(itrial,3-side)= E_input(itrial,side) + randi([1 4]);
        elseif E_input(itrial,side)>= 9 && E_input(itrial,side) <= 11
            E_input(itrial,3-side)= E_input(itrial,side) + randi([1 3+(9-E_input(itrial,side))]);
        end
        
   elseif E_mod(itrial) == 2
        E_input(itrial,side)= randi([0 7]);
        if E_input(itrial,side)<5
            E_input(itrial,3-side)= E_input(itrial,side) + randi([5 8]);
        elseif E_input(itrial,side)>= 5 && E_input(itrial,side) <= 7
            E_input(itrial,3-side)= E_input(itrial,side) + randi([5 8+(5-E_input(itrial, side))]);
        end
        
   elseif E_mod(itrial) == 3
        E_input(itrial,side)= randi([0 3]);
        E_input(itrial,3-side)=E_input(itrial,side)+randi([9, 12-E_input(itrial,side)]);
   end
end

% put all in a single variable
RE_input = [R_input E_input R_mod E_mod];

%shuffle the order of the trials
RE_input = Shuffle(RE_input,2);
 
% save the schedule
save(fullfile(FolderPath,'RE_input'),'RE_input')
save(fullfile(FolderPath,'RE_input.txt'),'RE_input', '-ascii','-tabs')


    
