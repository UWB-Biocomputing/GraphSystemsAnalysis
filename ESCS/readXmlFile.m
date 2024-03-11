
function simOutput = readXmlFile(fileName)

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