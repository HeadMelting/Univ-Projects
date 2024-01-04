function [arrQM] = LoadQM(qmlists)
arrQM = [];
for i=1:length(qmlists)
    
    qm = importdata(qmlists{i});
    
    arrQM = [arrQM;qm];

end

end

