%% This was to see if I can make the visuals more fun and engaging! 


% the parameters
n = pi/7;       
r = 5;          
a = 0:2*pi/3:2*pi; 

% creating figure for visualization
figure;
hold on;
axis equal;
grid on;
xlabel('X-axis', 'Color', 'w');
ylabel('Y-axis', 'Color', 'w');
title('Spinning Triangle Visualization', 'Color', 'w');
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');

% looping through 50 stars
for i = 1:50
    if (i < 37)
        color = 'm';
    else
        color = 'g';
    end
    
    % magenta and green colors for example

    % calculate the angle and coordinates
    m = i; % You can adjust m as needed, here it's simply i for now
    theta = a + n * m;  
    x = r * cos(theta); 
    y = r * sin(theta); 

    plot(x, y, color, 'LineWidth', 2); 

    drawnow;
    pause(0.05); % this can be adjusted 
end
hold off;