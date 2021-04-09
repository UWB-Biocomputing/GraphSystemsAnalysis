%use readXmlSTDP to generate graph G using the output files
%Histogram for minimum distance from the border of the network

%Calculating minimum distance of all neurons from the border
minDist=[];
for i=1:numNeurons
    A=[xloc(i), yloc(i), 99-xloc(i), 99-yloc(i)];
    minDist(i)=min(A);
end

minDist=reshape(minDist, 10000, 1);



%2D histograms with one axis for centrality values and the other for
%distance from the border
bet=centrality(G,'betweenness');
histogram2(bet, minDist, 10)
xlabel('Betweenness Values')
ylabel('Distance from nearest border')
zlabel('Number of Neurons')
title('Distribution of Betweenness Centrality Values based on distance from nearest border')

indeg = centrality(G,'indegree');
histogram2(indeg, minDist, 10)
xlabel('Indegree Centralilty')
ylabel('Distance from nearest border')
zlabel('Number of Neurons')
title('Distribution of Indegree Centrality Values based on distance from nearest border')

outdeg = centrality(G,'outdegree');
histogram2(outdeg, minDist, 10)
xlabel('Outdegree Centralilty')
ylabel('Distance from nearest border')
zlabel('Number of Neurons')
title('Distribution of Outdegree Centrality Values based on distance from nearest border')

pg_rank = centrality(G,'pagerank');
histogram2(pg_rank, minDist, 10)
xlabel('PageRank Centralilty')
ylabel('Distance from nearest border')
zlabel('Number of Neurons')
title('Distribution of PageRank Centrality Values based on distance from nearest border')
