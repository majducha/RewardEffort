%% ANALYSIS

%% COMMON
% Define variables common for both analyses
FolderPath = fullfile ('C:', 'Users', 'Majda', 'Documents', 'UNI', 'uni_matlab');
sub_ID = 's01';

% Get Schedule file
load(fullfile(FolderPath, 'RE_input.mat'));

% Get reward/effort difference levels
bx = RE_input(:,5:6);

% Get particiapnt's response file
responses = load(fullfile (FolderPath,horzcat('RE_', sub_ID, '.mat')));
options = table2array(responses.output(:,1)); % 0=left, 1=right
options(options ==0) = -1; %replaces 0s by -1s 


%% 9box - Choice analysis
% Extracts the information about reward and effort differences in each trial 
% and saves them into matrix (3 levels of effort x 3 levels of reward x  2 levels for percentage of trials when
% the higher reward was taken.

% define variables
FileName = strcat(sub_ID,'- HR - 9box');
GraphRange = [1 100];

%pre-allocate counter for the responses
respcounter = zeros(3,3,2); 
    
    % Create a results matrix with 3 levels for effort, 3 for reward and 2 for types of response
    % For E,R: 1=small difference between options, 2= medium difference, 3 = large difference
    % For Types of response: 1 = how often chosen the high rew opt; 2= total opts chosen)

% Count the Responses in each condition
for itrial = 1:length(RE_input)
        if sign(RE_input(itrial,4)-RE_input(itrial,3)) == options(itrial) 
        % If the above true then participant took the option with a higher reward
        % Would not work if the rewards fot both options were the same but that never happened
        
        % if higher reward was chosen, add 1 to the results matrix at a position with identical effort, reward differences
        respcounter(bx(itrial,2),bx(itrial,1),1) = respcounter(bx(itrial,2),bx(itrial,1),1) +1;
         
        end
        
    % Count a total number of trials that have the same r,e differences
    respcounter(bx(itrial,2),bx(itrial,1),2) = respcounter(bx(itrial,2),bx(itrial,1),2) +1; 
end

% Plot it 
    ticklabels = {'LOW','MED','HIGH'};
    data = 100*respcounter(:,:,1)./respcounter(:,:,2);
    graph1 = figure('Name',MyTitle);
    imagesc(data,GraphRange);
    colorbar;
    ylabel('Effort Difference');
    set(gca,'YTickLabel',ticklabels);
    set(gca,'YTick',[1 2 3]);
    xlabel('Reward Difference');
    set(gca,'XTickLabel',ticklabels);
    set(gca,'XTick',[1 2 3]);
    saveas (gca,fullfile (FolderPath,horzcat(FileName, '.png')));
    
 %% Logistic regression
 
 % Create variable responseHR than stores when the high reward/high effort option was chosen
responseHR = nan(length(options),1);
for itrial = 1:length(RE_input)
    if sign(RE_input(itrial,4)-RE_input(itrial,3)) == options(itrial) 
       
        responseHR(itrial,1) = 1;
        
    else
        responseHR(itrial,1) = 0;
       
    end
end

% Create labels for the graph depending on the predictors
labels = {'','constant','','reward Dif','', 'effort Dif'};

% Run Logistic regression 
    mdl = GeneralizedLinearModel.fit(bx(:,:),responseHR,'distribution','binomial','link','logit');
    
% Plot it

figure
hold on
bar(mdl.Coefficients.Estimate)
errorbar(mdl.Coefficients.Estimate,mdl.Coefficients.SE,'.')
set(gca,'XTickLabel',labels)
MyTitle = strcat(sub_ID, ' _ER_glm'); 
saveas (gca,MyTitle, 'png')


