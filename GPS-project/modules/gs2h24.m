function [h24] = gs2h24(gs)

h24 = mod(gs,86400)/3600;