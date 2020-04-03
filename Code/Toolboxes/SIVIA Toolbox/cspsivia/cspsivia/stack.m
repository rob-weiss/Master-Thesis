classdef stack < handle
% STACK A stack data structure (last in - first out).
%
% Properties:
%   data     - an array of items in the stack
%   counter  - number of items contained in the stack
%   capacity - capacity of the stack
%
% Methods:
%   isempty - gets a value indicating wheter the stack is empty
%   push    - inserts an item at the top of the stack
%   pop     - returns and removes the item at the top of the stack
%   top     - returns the item at the top of the stack
%   items   - returns an array of all items in the stack

    properties (SetAccess = private)
        data
        counter    
        capacity
    end
    
    methods
        function s = stack()
                s.data = cell(100, 1);
                s.counter = 0;
                s.capacity = 100;
        end

        function e = isempty(this)            
            e = (this.counter == 0);
        end

        function push(this, item)
            if this.counter == this.capacity 
                % capacity limit reached, double it
                this.data(this.capacity+1 : 2*this.capacity) = cell(this.capacity, 1);
                this.capacity = 2*this.capacity;
            end
            this.counter = this.counter + 1;
            this.data{this.counter} = item;
        end
        
        function item = pop(this)
            if this.counter == 0
                error('stack:Empty', 'Cannot pop an element from an empty stack!');
            else
                item = this.data{this.counter};
                this.counter = this.counter - 1;
            end        
        end
        
        function item = top(this)
            if this.counter == 0
                % the stack is empty
                item = [];
            else
                item = this.data{this.counter};
            end        
        end
        
        function s = items(this)
            s = this.data(1:this.counter);
        end
    end
end