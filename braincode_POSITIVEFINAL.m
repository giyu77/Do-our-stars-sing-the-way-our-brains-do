%% Braincode

%% description of dataset (below is from Kaggle for your and my reference) 
% Up - Negative (Walt Disney Pictures)
% Opening Death Scene
% My Girl - Negative (Imagine Entertainment)
% Funeral Scene
% La La Land - Positive (Summit Entertainment)
% Opening musical number
% Slow Life - Positive (BioQuest Studios)
% Nature timelapse
% Funny Dogs - Positive (MashupZone)
% Funny dog clips

%The dataset consists of EEG brainwave data collected from two individuals (one male and one female) using a Muse 
% EEG headband, with four electrode placements (TP9, AF7, AF8, and TP10) to monitor brain activity during emotional states (positive, neutral,
% negative) evoked by stimuli from various movies. Statistical features were extracted from the brainwave signals, 
% which were resampled to capture the temporal characteristics of the waves for classification tasks related to 
% mental and emotional sentiment. The dataset can be used to discern emotional states like “feeling good” by analyzing
% the patterns in the EEG data associated with positive emotions.
% The “mean” columns in the dataset likely refer to the average values of specific statistical features 
% (e.g., mean power or amplitude) extracted from the EEG signals, calculated over the time window for each emotional state. 
% These mean values would represent a summary of brain activity for each channel and emotional condition, helping to characterize mental states based on the EEG data.

%% getting the data 
% unzip the file
unzip('emotions.csv.zip', 'temp_folder'); % extracting the contents to a temporary folder
data2 = readtable(fullfile('temp_folder', 'emotions.csv'), 'VariableNamingRule', 'preserve');

% delete folder that was created 
rmdir('temp_folder', 's');

%% Constants and Setup that I used from stars code bland (first code chunk I made) 
Fs = 8000; 
t = 0:1/Fs:1;
Freqs = [440, 494, 523, 587, 659, 698, 784]; 

% creating notes - again taken from previous code 
Notes = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};
note_signals = containers.Map(Notes, arrayfun(@(f) sin(2 * pi * f * t), Freqs, 'UniformOutput', false));

%% Filter data to include only rows with label 'NEGATIVE' and limit to first 100 rows
data_subset = data2(strcmp(data2.label, 'POSITIVE'), :);
data_subset = data_subset(1:min(100, height(data_subset)), :); % limiting to first 100 rows because the dataset was too large 
%% Assign Notes Based on Value Ranges
% defining the ranges that will relate to the notes 
note_ranges = [-Inf, 0; 0, 10; 10, 20; 20, 30; 30, 40; 40, 50; 50, Inf];
note_labels = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};

% initializing an empty cell array for note assignments
note_assignments = cell(size(data_subset, 1), size(data_subset, 2) - 1); 

% looping through the columns and rows to assign notes
for col = 1:width(data_subset) - 1 % take out the label column 
    for row = 1:height(data_subset) % iterating over all rows in the filtered subset
        value = data_subset{row, col};  % extracting the value from the cell
        if isnumeric(value)  % if the value is numeric
% match range 
                for n = 1:size(note_ranges, 1)
                if value >= note_ranges(n, 1) && value < note_ranges(n, 2)
                    note_assignments{row, col} = note_labels{n};
                    break;
                end
            end
        end
    end
end

% converting note assignments to a table with the same column names
notes_table = array2table(note_assignments, 'VariableNames', data_subset.Properties.VariableNames(1:end-1)); % again exclude 'label' column

%% Display the result
%disp(notes_table); was taking up space

%% Plot Notes and Play Music
% set up the figure for plotting
figure;
hold on;
colors = {'r', 'g', 'b', 'm', 'c', 'y', 'k'}; % colors for the notes A-G

combined_signal = [];

% iterating over the notes and play them
for col = 1:width(data_subset) - 1 
    for row = 1:height(data_subset) 
        note = note_assignments{row, col};
        
% play the corresponding note 
        player = audioplayer(note_signals(note), Fs);
        play(player);
        
% random tempo variation 
        pause(rand * 0.7 + 0.8);
        
        % plotting a scatter point for each note played
        scatter(col, row, 100, colors{find(strcmp(note_labels, note))}, 'filled');
    end
end

% setting plot labels and title
xlabel('Columns');
% setting background color to black and adjust axis properties for visibility
ylabel('Rows'); set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w'); 

title('Scatter Plot of Notes Played');

hold off;