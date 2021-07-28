classdef FieldDouble < Field
    %FIELDDOUBLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Arr;
        Limits;
        HasLimits;
        Unit;
    end
    
    methods
        function obj = FieldDouble(parent)
            obj@Field(parent);
            obj.Type='double';
        end
        

        

    end
    
    methods %abstract
        
        function stash=CoPack(obj)
            stash=struct;
        end
        
        
        function CoPopulate(obj,stash)
        end
        
        
        function DrawGui(obj)
        end
        
        function ou=GetOutput(obj)
        end
    end
end

