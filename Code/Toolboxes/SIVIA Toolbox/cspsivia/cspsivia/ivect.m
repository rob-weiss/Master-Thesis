classdef ivect < handle
% IVECT An expanding data structure containing interval vectors. 
%   IVECT Can be used for faster insert when the size of the resulting vector 
%   is unknown (and thus it cannot be pre-allocated).
%
%   Properties:
%       data     - a vector of interval vectors containing inserted items
%       counter  - number of inserted items
%       capacity - capacity of the vector
%
%    Methods:
%       insert    - inserts an item
%       insertset - insert more items, rows of a matrix
%       items     - returns a vector of all inserted items
%
    
    properties (SetAccess = private)
        data
        counter
        capacity
    end
    
    methods
        function v = ivect(dim)
            v.data = intval(zeros(1, dim));
            v.counter = 0;
            v.capacity = 1;
        end
        
        function insert(this, item)
            this.counter = this.counter + 1;
            this.data(this.counter, :) = item;
            if (this.counter == this.capacity) 
            % limit reached, double the capacity
                this.capacity = 2*this.capacity;
                this.data(this.counter+1:this.capacity, :) = 0;
            end
        end
        
        function insertset(this, item)
            beg = this.counter + 1;
            this.counter = this.counter + size(item, 1);
            while (this.counter >= this.capacity) 
            % limit reached, double the capacity
                this.capacity = 2*this.capacity;
                this.data(this.counter+1:this.capacity, :) = 0;
            end
            this.data(beg:this.counter, :) = item;
        end
        
        function v = items(this)
            this.data(this.counter+1:end,:) = [];
            v = this.data;
        end
    end
    
end

