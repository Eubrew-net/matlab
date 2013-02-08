%% sparklines
%  Modified by Mike Kidner Jan 18 2010
%  James Houghton
%  James.P.Houghton@gmail.com
%  December 4 2009
%
% This code based upon:
%  
%  Edward Tufte: Visual Display of Quantitative Information,
%  Second Edition
%  Graphics Press
%  pg 171
%
%% ToDo:
%
% # expand labels column to allow wider labels
% # clean up numerical data columns by fixing the number of sig. figs. DONE
% MRFK: included optional format string
% # make the title argument optional- DONE
% # change the way elements are laid out to something other than fractions of window size.
% # add a way to change the size of the figure window based upon how many sparklines there are
% # make drawing parameters user modifiable

%% Function Definition
% Inputs:
%
% * *t* - horizontal array of length n representing time values for all sparklines
% * *m* - m by n matrix of data. Each row contains data for a new sparkline.
% * *labels* - vertical cell array of length m, containing a string for each sparkline
% * *title* - title of the sparklines, (probably wants to be an optional input)
%
% Outputs:
%
% * *h* - handle to the figure created
%
function [h] = sparklines(t, m, varargin)
%% Set defaults

    labels = cellstr(char(repmat(32, size(m)))); %a cell array of spaces, 32 is ASCII code for space
    title_str = '';
    numformat = '%2.2f';
    aspect = 500;
    fontsize = [12, 14]; 
    maxmin = true;
    header = true;
    showstart = true;

%% Get the arguments
if nargin > 1
   argl = length(varargin);
   if rem(argl,2) ~= 0
       error('Optional inputs must be in format ''variable name'',variable value')
   end
   for ii = 1:2:argl
       if strcmp(varargin{ii},'Labels')
            labels = varargin{ii+1};
       end
       if strcmp(varargin{ii},'Title')
            title_str = varargin{ii+1};
       end
       if strcmp(varargin{ii},'NumberFormat')
            numformat = varargin{ii+1};
       end
       if strcmp(varargin{ii},'Aspect')
            aspect = varargin{ii+1};
       end
       if strcmp(varargin{ii},'FontSize')
            fontsize = varargin{ii+1};
       end
       if strcmp(varargin{ii},'Header')
            header = varargin{ii+1};
       end
       if strcmp(varargin{ii},'RangeBox')
            range = varargin{ii+1};
       end
         if strcmp(varargin{ii},'ShowMaxMin')
            maxmin = varargin{ii+1};
         end
          if strcmp(varargin{ii},'ShowStartValue')
            showstart = varargin{ii+1};
       end
       
   end
end



%% Create the figure
% create a new figure object
h=figure('Name','Sparklines', 'Units', 'inches','Color','w');
spark_height = fontsize(1)/72; %inches
spark_width = aspect*spark_height;

%% drawing parameters
% This is where we define the overall shape of the table.
% Units are in fractions of total window width, a sub-optimal solution 

% Each sparkline should be about 1 line height in size, ie 14pt.
spark_height =  spark_height;                 % vertical height of sparkline axis 
spark_spacing=  (1.5*fontsize(1)/72);                % distance between successive sparklines
text_height =  (2*fontsize(1)/72);                  % height of all text boxes, distance between text boxes
sep = (0.5*fontsize(1)/72);

fig_height = (size(m,1))*(spark_height + spark_spacing)/1.5+text_height+sep;

spark_width  = (spark_width/72);                   % width of sparkline
value_width = 0.5*length([sprintf(numformat,pi)]) * (fontsize(end)/72);                   % width of sparkline labels
label_width = size(char(labels),2)*(fontsize(1)/72);                   % width of all numerical elements
x_spark = label_width + value_width + 2*sep;                       % horizontal position of left end of sparklines



%|<---x_spark---->|/\/\/\//\/\\/\/\\/\|
%                 <----spark_width--->
%|<---x_left-->|  |<- value width
%|<-x_label->|
%|          >| |<- label_width
%|<-------------x_right-------------->|   |<- value width
%|<-----------------x_min---------------->|   |<- value width
%|<------------------x_max-------------------->

x_left = x_spark - value_width-sep;     % horizontal position of left end of left value
x_label = x_left - label_width - sep;     % horizontal position of left end of sparkline lable
x_right = x_spark + spark_width + sep;    % horizontal position of left end of right value
x_min = x_right + value_width + sep;      % horizontal position of left end of minimum value
x_max = x_min + value_width+ sep;        % horizontal position of left end of maximum value


fig_width = x_max+value_width+sep;
set(h,'Position', [1 1 fig_width fig_height]);

y_line = (fig_height - text_height)/fig_height;                        % vertical position of separator line
y_column_labels = y_line - sep/fig_height;       % vertical position of column labels

x_left = x_left/fig_width;
x_max = x_max/fig_width;
value_width = value_width/fig_width;
x_label = x_label/fig_width;
x_right = x_right/fig_width;
x_spark = x_spark/fig_width;
x_min=x_min/fig_width;
label_width = label_width/fig_width;
spark_width = spark_width/fig_width;

text_height=text_height/fig_height;
spark_height = spark_height/fig_height;
sep = sep/fig_height;
spark_spacing = spark_spacing/fig_height;
%% set up the table outline
% This is where we paint the line and column headings for the table.
if(header)

% create a grey horizontal line
annotation('line', [x_left, x_max+value_width], [y_line, y_line], 'Color', [.9, .9, .9]);

% display the sparkline title
annotation('textbox', [x_spark, y_column_labels, spark_width, text_height], ...
           'string', title_str, ...
           'HorizontalAlignment', 'Center', ...
           'LineStyle', 'none',...
       'FontSize',fontsize(1));

% display the left and right end time value
annotation('textbox', [x_left, y_column_labels, value_width, text_height], ...
           'string', sprintf(numformat,t(1)), ...
           'HorizontalAlignment', 'Right', ...
           'LineStyle', 'none', 'FontSize', fontsize(1));
annotation('textbox', [x_right, y_column_labels, value_width, text_height], ...
           'string', sprintf(numformat,t(end)), ...
           'HorizontalAlignment', 'Left', ...
           'LineStyle', 'none', 'FontSize', fontsize(1));
       
% label the max and min columns
annotation('textbox', [x_min, y_column_labels, value_width, text_height], ...
           'string', 'mean', ...
           'HorizontalAlignment', 'Center', ...
           'LineStyle', 'none', 'FontSize', fontsize(1));
annotation('textbox', [x_max, y_column_labels, value_width, text_height], ...
           'string', 'mean (osc<.7)', ...
           'HorizontalAlignment', 'Center', ...
           'LineStyle', 'none', 'FontSize', fontsize(1));    
end       
%% generate individual sparklines
for(i = 1:size(m,1))                                % for all the rows in the input array
    % figure out the y location of the current row
    y_thiselement = y_line-spark_spacing*i-sep;     % the .03 gives a nice offset from the horizontal line
    
    % create an axis for this sparkline
    axes('position',[x_spark,  y_thiselement+.75*spark_height,  spark_width,  spark_height])
    
    % find the extreem values (to highlight)
    [miny, minxi] = min(m(i,:));            
    [maxy, maxxi] = max(m(i,:));   
    % average and std
    mean_=nanmean(m(i,:));
    mean_2=nanmean(m(i,t<0.7));
    j1=find(~isnan(m(i,:)),1,'first');
    jend=find(~isnan(m(i,:)),1,'last');
    
    
    %Draw the rnage box in the background if requested
    if(exist('range','var'))
        rbox = patch(t([j1,j1,jend,jend]),range([1,2,2,1]),[0.8 0.8 0.8]);
        set(rbox,'EdgeColor','w')
        hold on
    end
    
    % plot the data
    lines=plot(t,m(i,:), '-k', ...                  
         t(minxi), m(i,minxi), 'b.', ...            % highlight the min and max values blue
         t(maxxi), m(i,maxxi), 'b.', ...
         t(j1), m(i,j1), 'r.', ...                    % highlight the end values red
         t(jend), m(i,jend), 'r.');
    
    % format the axes
    set(lines,'LineWidth',2);
    set(gca, 'Visible', 'off');                     % Turn off the axes
    axis tight;                                     % fit the data in the axes
    
    % add the row label
    annotation('textbox', [x_label, y_thiselement, label_width, text_height], ...
               'string', labels{i}, ...
               'HorizontalAlignment', 'right', ...
               'LineStyle', 'none');
           
    % add values for the left and right end
    if(showstart)
%     if isnan(m(i,end))
%         k=find(~isnan(m(i,:)),1,'last');
%         if ~isempty(k)
%           m(i,end)=m(i,k);
%         end
%     end
    annotation('textbox', [x_left, y_thiselement, value_width, text_height], ...
               'string', sprintf(numformat,m(i,j1)), ...
               'HorizontalAlignment', 'right', ...
               'LineStyle', 'none', ...
               'Color', 'r', 'FontSize', fontsize(end));
    end
    annotation('textbox', [x_right, y_thiselement, value_width, text_height], ...
               'string', sprintf(numformat,m(i,jend)), ...
               'LineStyle', 'none', ...
               'Color', 'r', 'FontSize', fontsize(end));
           
    % add values for median 
    if(maxmin)
    annotation('textbox', [x_min, y_thiselement, value_width, text_height], ...
               'string', sprintf(numformat,mean_), ...
               'HorizontalAlignment', 'center', ...
               'LineStyle', 'none', ...
               'Color', 'b', 'FontSize', fontsize(end));
    annotation('textbox', [x_max, y_thiselement, value_width, text_height], ...
               'string', sprintf(numformat,mean_2), ...
               'HorizontalAlignment', 'center', ...
               'LineStyle', 'none', ...
               'Color', 'b', 'FontSize', fontsize(end));
    end
end