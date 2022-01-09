classdef FieldDateTime < Field
    %FIELDDATETIME Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        DateTime;
        Format;
        State=false;
    end
    
%     properties (Dependent)
%         Count;
%     end
    
    methods
        function obj = FieldDateTime(parent)
            obj@Field(parent);
            obj.Type='datetime';
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

