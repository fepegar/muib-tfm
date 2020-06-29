function labels = grLabel(nodes, edges)
    %GRLABEL associate a label to each connected component of the graph
    %   LABELS = grLabel(NODES, EDGES)
    %   Returns an array with as many rows as the array NODES, containing index
    %   number of each connected component of the graph. If the graph is
    %   totally connected, returns an array of 1.
    %
    %   Example
    %       nodes = rand(6, 2);
    %       edges = [1 2;1 3;4 6];
    %       labels = grLabel(nodes, edges);
    %   labels =
    %       1
    %       1
    %       1
    %       2
    %       3
    %       2   
    %
    %   See also
    %   getNeighbourNodes
    %
    %
    % ------
    % Author: David Legland
    % e-mail: david.legland@grignon.inra.fr
    % Created: 2007-08-14,    using Matlab 7.4.0.287 (R2007a)
    % Copyright 2007 INRA - BIA PV Nantes - MIAJ Jouy-en-Josas.

    % init
    Nn = size(nodes, 1);
    labels = (1:Nn)';

    % iteration
    modif = true;
    while modif
        modif = false;

        for i=1:Nn
            neigh = getNeighbourNodes(i, edges);
            neighLabels = labels([i;neigh]);

            % check for a modification
            if length(unique(neighLabels))>1
                modif = true;
            end

            % put new labels
            labels(ismember(labels, neighLabels)) = min(neighLabels);
        end
    end

    % change to have fewer labels
    labels2 = unique(labels);
    for i=1:length(labels2)
        labels(labels==labels2(i)) = i;
    end
end

function nodes2 = getNeighbourNodes(node, edges)
    %GETNEIGHBOURNODES find nodes adjacent to a given node
    %
    %   NEIGHS = getNeighbourNodes(NODE, EDGES)
    %   NODE: index of the node
    %   EDGES: the complete edges list
    %   NEIGHS: the nodes adjacent to the given node.
    %
    %   NODE can also be a vector of node indices, in this case the result is
    %   the set of neighbors of any input node.
    %
    %
    %   -----
    %
    %   author : David Legland 
    %   INRA - TPV URPOI - BIA IMASTE
    %   created the 16/08/2004.
    %

    %   HISTORY
    %   10/02/2004 documentation
    %   13/07/2004 faster algorithm
    %   03/10/2007 can specify several input nodes

    [i, j] = find(ismember(edges, node));
    nodes2 = edges(i,1:2);
    nodes2 = unique(nodes2(:));
    nodes2 = sort(nodes2(~ismember(nodes2, node)));
end

