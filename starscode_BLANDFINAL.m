%% BSCI 3270 Final Project - Do Our Brains Sing the Way Stars Do?
% By Gina Yu

%% data description 

%This project explores the connection between the characteristics of stars and musical notes, 
% mapping spectral classes of stars to musical notes and visualizing the stars based on their properties such as distance, 
% luminosity, and radius. The dataset contains information about various stars, including their spectral class, luminosity, radius, 
% and distance, allowing for an exploration of the diversity of stars in our galaxy. The dataset is used to generate musical notes 
% corresponding to each star’s spectral class, with the volume of each note influenced by the star’s distance and the luminosity affecting its
% transparency. The project includes a function that sorts stars by distance and plays corresponding notes while visualizing the stars as markers in a scatter plot. 
%This approach offers an innovative way to blend astronomy with music, providing both auditory and visual representations of stellar data.

%% Data Loading

% Load star dataset
data = readtable('star_dataset.csv');

% Load circadian rhythm data
data2 = readtable('data141110.csv');

%% Constants and Setup
% this is the sampling frequency + time vector for notes + the frequencies
% for a-g that I found online
Fs = 8000;
t = 0:1/Fs:1; % Time vector for notes
Freqs = [440, 494, 523, 587, 659, 698, 784]; 

% create notes and create a container for these notes so that i can map it
% onto the spectral classes later
Notes = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};
note_signals = containers.Map(Notes, arrayfun(@(f) sin(2 * pi * f * t), Freqs, 'UniformOutput', false));

% mapping the spectral classes + notes
% first find which spectral class names are unique 
spectral_classes = unique(data.SpectralClass);
disp('Spectral Classes:');
disp(spectral_classes);

% list of the spectral classes from the output above 
spectral_classes = {'A0V', 'A1V', 'A2Ia', 'A3V', 'A7V', 'A9II', ...
                    'B0.5IV', 'B0Ia', 'B1III', 'B1III-IV', 'B2III', 'B6Vep', ...
                    'B7V', 'B8Ia', 'F5IV-V', 'F7Ib', 'G2V', 'G8III', ...
                    'K1.5III', 'K1V', 'K5III', 'M1.5Iab', 'M2.1V', 'M2Iab', ...
                    'M3.5V', 'M4Ve', 'M6V', 'M7IIIe'};

% notes to assign
notes = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};

% mapping the spectral classes to notes evenly
spectral_to_notes = containers.Map();
for i = 1:length(spectral_classes)
    note = notes{mod(i-1, length(notes)) + 1};  
    spectral_to_notes(spectral_classes{i}) = note;
end

% show this in a separate visual to make sure it works 
disp('Spectral Class to Note Mapping:');
keys = spectral_to_notes.keys;
values = spectral_to_notes.values;
for i = 1:length(keys)
    fprintf('%s -> %s\n', keys{i}, values{i});
end

%% Function: Play Notes Ordered by Short to Long Distance
function play_notes_by_star_luminosity(data, spectral_to_notes, note_signals, Fs)
    % sorting the data by luminosity (smallest to brightest)
    sorted_data = sortrows(data, 'Luminosity_L_Lo_');

    % normalizing  distances to control volume
    distances = sorted_data.Distance_ly_;
    normalized_volumes = normalize(distances, 'range', [0.1, 1]);

    % normalizing luminosity for transparency and for brightness
    luminosity = sorted_data.Luminosity_L_Lo_;
    normalized_luminosity = normalize(luminosity, 'range', [0.2, 1]);

    % normalizing the radius for marker size
    radius = sorted_data.Radius_R_Ro_;
    normalized_radius = normalize(radius, 'range', [5, 500]);  % Smaller size range

    % assigning the colors for each spectral class
    spectral_classes = unique(sorted_data.SpectralClass);
    colors = lines(length(spectral_classes));
    class_to_color = containers.Map(spectral_classes, num2cell(colors, 2));

    % a scatter plot with black background
    figure;
    hold on;
    grid on;
    xlabel('Distance (light years)', 'Color', 'w');
    ylabel('Luminosity (L/L_o)', 'Color', 'w');
    title('Star Visualization by Distance with Music', 'Color', 'w');
    set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');

    % cycling through sorted stars and play corresponding notes
    for i = 1:height(sorted_data)
        class = sorted_data.SpectralClass{i};
        if isKey(spectral_to_notes, class)
            note = spectral_to_notes(class);
            signal = note_signals(note) * normalized_volumes(i);

            % star properties
            x = sorted_data.Distance_ly_(i);
            y = sorted_data.Luminosity_L_Lo_(i);
            color = class_to_color(class);
            alpha_val = normalized_luminosity(i);
            size = normalized_radius(i);

            % draw star marker
            theta = linspace(0, 2*pi, 6);
            r = size / 50;
            star_x = x + r * cos(theta);
            star_y = y + r * sin(theta);
            fill(star_x, star_y, color, 'EdgeColor', 'none', 'FaceAlpha', alpha_val);

            % updating the plot
            drawnow;

            % playing the sound!
            sound(signal, Fs);

            % random tempo variation or you can think of it as pauses 
            pause(rand * 0.7 + 0.8);
        end
    end
    hold off;
end

%% Play Notes Ordered by Distance (Short to Long)
disp('Playing stars by luminosity (volume based on distance)...');
play_notes_by_star_luminosity(data, spectral_to_notes, note_signals, Fs);