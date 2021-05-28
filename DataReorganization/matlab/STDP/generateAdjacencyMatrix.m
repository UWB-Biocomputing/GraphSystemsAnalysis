
% run readXMLSTDP script for generating s, t and w

totalSynapses=size(s,2);
numNeurons=max(s);
%area matrix represents the adjacencvy matrix for 
area=zeros(numNeurons, numNeurons);
for i = 1:(totalSynapses)
    %x=mod(s(1,i),100)+1;
    x=s(1,i);
    y=t(1,i);
    %y=mod(t(1,i), 100)+1;
    area(x,y)=w(1,i);
    %area(x,y)=w(1,i)*10^7;
    area(y,x)=area(x,y);
end

adjMat=area;
%finding minimum value greater than zero to add to the weights
%this allows us to do log normalization
min=1;
for i=1:numNeurons
    if(area(i)<min & area(i)>0)
        min=area(i);
    end
end

areaNormalized=area+min;

%plotting the normialized ajacency matrix
imagesc(real(log(areaNormalized)))
%colormap parula
%colormap jet
%colorbar
%axis equal
%xlabel('Neuron Index','FontSize', 15)
%ylabel('Neuron Index','FontSize', 15)
%title('After STDP Simulation for 5 sec','FontSize', 15)


