%specify the name of the file that you want to read
x=xmlread("stdp.xml");
%the document element is simState
simState=x.getDocumentElement;
%the child nodes of simState represent the data stored
entries=simState.getChildNodes;
%the numbering of the childNodes is off by one
%1-sourceIndex, 3-destIndex, 5-weights, 7-burstiness, 9-spikehistory
%11-xloc, 13-yloc, 15-neuronType, 17-starterNeuron, 21-TSim,
%23-SimulationEndTime

%source neuron index
sourceNeuron=entries.item(1);
%attributes of the node give the name, columns, row
attrSource = sourceNeuron.getAttributes;
%the attributes are ordered alphabetically while reading
%0-columns, 1-multiplier, 2-name, 3-rows, 4-type
nameOfMatrix=attrSource.item(2);
%getting the values of these parameters and converting to double arrays
sourceData=str2num(sourceNeuron.getTextContent);

%dest neuron index
destNeuron=entries.item(3);
destData=str2num(destNeuron.getTextContent);
%weights
weights=entries.item(5);
weightData=str2num(weights.getTextContent);

numRow=size(weightData,1);
%concatenating and deleteing the zero values
s=sourceData(numRow, :);
t=destData(numRow, :);
w=weightData(numRow,:);
C1=cat(1, s, t);
C1=cat(1, C1, w);
TF1 = C1(1,:)==0 ;
C1(:, TF1) = [];
TF1 = C1(2,:)==0 ;
C1(:, TF1) = [];

%separating for graph plotting
s=C1(1, :);
t=C1(2,:);
w=C1(3,:);

G = digraph(s,t,w);
GUndirected=graph(s,t,w);
plot(G)
plot(G,'Layout','force')
