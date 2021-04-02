%use readXmlSTDP to generate graph G using the output files

%3D scatter plots,  Points plotted indicate degree centrality value for each
%neuron. Centrality values are shown as both as the Z coordinate and as point color.
bet=centrality(G,'betweenness');
S = repmat([70],10000,1);
scatter3(xloc, yloc, bet, S, bet, 'filled')
colorbar
xlabel('X axis', 'FontSize', 15)
ylabel('Y axis', 'FontSize', 15)
zlabel('Betweeness Values', 'FontSize', 15)
title('Betweenness Centrality Values: 300 sec', 'FontSize', 15)


pg_rank = centrality(G,'pagerank');
scatter3(xloc, yloc, pg_rank, S,pg_rank , 'filled')
colorbar
xlabel('X axis')
ylabel('Y axis')
zlabel('Page Rank')
title('Page Rank Centrality')

indeg = centrality(G,'indegree');
scatter3(xloc, yloc, deg, S,deg , 'filled')
colorbar
xlabel('X axis')
ylabel('Y axis')
zlabel('Indegree Centrality')
title('Indegree Centrality Values')

outdeg = centrality(G,'outdegree');
scatter3(xloc, yloc, deg, S,deg , 'filled')
colorbar
xlabel('X axis')
ylabel('Y axis')
zlabel('Outdegree Centrality')
title('Outdegree Centrality Values')

%histograms; distribution plots
%Distribution of degree centrality for all neurons at the end of growth simulation.
%X axis represents the indegree centrality value for the histogram bins and Y axis
%shows the number of neurons in the bin.

histogram(bet, 10)
xlabel('Betweenness Values')
ylabel('Number of Neurons')
title('Distribution of Betweenness Centrality Values')

histogram(indeg, 10)
xlabel('Indegree Centrality Values')
ylabel('Number of Neurons')
title('Distribution of Outegree Centrality Values')

histogram(outdeg, 10)
xlabel('Outdegree Centrality Values')
ylabel('Number of Neurons')
title('Distribution of Outdegree Centrality Values')


histogram(pg_rank, 10)
xlabel('PageRank Centrality Values')
ylabel('Number of Neurons')
title('Distribution of PageRank Centrality Values')
