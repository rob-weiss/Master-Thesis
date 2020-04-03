function [] = Runner(vis_count, size_of_x, size_of_y, varargin)

base_amount_of_params = 3;

current_vis = 0;
current_input_parameter = 0;
current_output_parameter = 0;

while_constr = true;
while (while_constr)
    current_input_parameter = current_input_parameter + 1;
    if (current_input_parameter > nargin - base_amount_of_params)
       break
    end
    
    current_vis = current_vis + 1; 

    if (strcmp(varargin{1,current_input_parameter}, 'matlab'))
        current_output_parameter = current_output_parameter + 1;
        varargout{current_output_parameter} = 'matlab';
        
        [T_min_X, T_max_X, T_min_Y, T_max_Y] = SplitBoxes(varargin{current_input_parameter + 1});
        [U_min_X, U_max_X, U_min_Y, U_max_Y] = SplitBoxes(varargin{current_input_parameter + 2});
        [F_min_X, F_max_X, F_min_Y, F_max_Y] = SplitBoxes(varargin{current_input_parameter + 3});
        varargout{current_output_parameter + 1} = T_min_X;
        varargout{current_output_parameter + 2} = T_max_X;
        varargout{current_output_parameter + 3} = T_min_Y;
        varargout{current_output_parameter + 4} = T_max_Y;
        varargout{current_output_parameter + 5} = U_min_X;
        varargout{current_output_parameter + 6} = U_max_X;
        varargout{current_output_parameter + 7} = U_min_Y;
        varargout{current_output_parameter + 8} = U_max_Y;
        varargout{current_output_parameter + 9} = F_min_X;
        varargout{current_output_parameter + 10} = F_max_X;
        varargout{current_output_parameter + 11} = F_min_Y;
        varargout{current_output_parameter + 12} = F_max_Y;

        current_input_parameter = current_input_parameter + 3;
        current_output_parameter = current_output_parameter + 12;
    elseif (strcmp(varargin{1,current_input_parameter}, 'file'))
        current_output_parameter = current_output_parameter + 1;
        varargout{current_output_parameter} = 'fileb';
        
        varargout{current_output_parameter + 1} = varargin{current_input_parameter + 1};
        varargout{current_output_parameter + 2} = varargin{current_input_parameter + 2};
        varargout{current_output_parameter + 3} = varargin{current_input_parameter + 3};
       
        current_input_parameter = current_input_parameter + 3;
        current_output_parameter = current_output_parameter + 3;
    else
       error('Wrong input parameters') 
    end
    
end

if (current_vis ~= vis_count)
   error('Wrong number of sets for visualisation') 
end

IntervalDataVisualiser(vis_count, size_of_x, size_of_y, varargout{:})

end