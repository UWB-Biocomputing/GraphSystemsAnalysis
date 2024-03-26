function simOutput = readXmlFile(fileName)
% readXmlFile.m Reads an XML ESCS simulation output file into a struct.
% The XML file format must conform to the one in the "test-data" directory.
% This is the format used in Graphitti's v0.9.2 release.
%
% Syntax: simOutput = readXmlFile("test-data/test-small-911-out.xml")
%
% Inputs:
%   fileName - Name of the simulation output file
%
% Outputs:
%   simOutput - struct that contains the ESCS simulation output
    S = readstruct(fileName);
    
    simOutput = struct;
    pat = " ";

    for node = S.Matrix
    
        val = 0;
    
        if ~ismissing(node.Text)
            if isnumeric(node.Text)
                val = node.Text;
            else
                val = str2doubleq2(cellstr(strsplit(node.Text, pat)));
            end
    
        elseif ~ismissing(node.vertex)
            val = cell(length(node.vertex), 1);
    
            for v = 1: length(node.vertex)
                if isnumeric(node.vertex(v).Text)
                    val{v} = node.vertex(v).Text;
                else
                    val{v} = str2doubleq2( ...
                                cellstr( ...
                                    strsplit(node.vertex(v).Text,pat) ...
                                    ));
                end
            end
     
        end
    
        simOutput.(node.nameAttribute) = val;
    end

end