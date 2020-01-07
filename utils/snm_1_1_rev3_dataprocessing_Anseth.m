% Anseth data processing
% 12.24.2019 JR
% 
% Conversion of initial data (from GEO entry/supplement) to a version
% useable by model fitting scripts. Also provides functionality to sweep
% scaling parameters to change range and/or center of data.
% 
% Files needed:
% - proteomics data ("aav3233_Data_file_S1.xlsx", as log2RFU)
% - transcriptomics data ("GSE133529_ProcessedDataFile.csv", as CPM)
% - Netflux model file ("snm_1_1_rev3.xlsx", for extracting snm data)
% 
% tic

% Get model inputs/outputs from model file
filepath = "snm_1_1_rev3.xlsx";
opts = detectImportOptions(filepath,'Sheet','species');
snm_species = readtable(filepath,opts,'Sheet','species');
opts = detectImportOptions(filepath,'Sheet','reactions');
snm_rxns = readtable(filepath,opts,'Sheet','reactions');

%%%% Output Data %%%%
% Specify + load output data files
filepath = "GSE133529_ProcessedDataFile.csv";
opts = detectImportOptions(filepath,"Range",[2 1]);
cpm = readtable(filepath, opts);
cpm = rmmissing(cpm,1);     % remove NaN rows

% Filter + Process output data
% ID outputs from model
output_id = strcmpi(snm_rxns.module,"output");
output_prot = split(snm_rxns.Rule(output_id),"=>");
output_prot = split(unique(output_prot(:,2))," ");
output_prot = output_prot(:,2);
% convert to gene names
output_genes = cell.empty(length(output_prot),0);
for output = 1:length(output_prot)
    idx = find(strcmpi(snm_species.ID, output_prot(output)));
    output_genes(output) = snm_species.geneName(idx);
end
output_genes = transpose(unique(output_genes));
% filter cpm data for output genes
for output = 1:length(output_genes)
    idx(output) = find(strcmpi(cpm.Var1, output_genes(output)));
end
output_cpm = cpm(idx,:);
% filter genes below threshold
cutoff = 0.5;
idx = find(~(mean(output_cpm{:,2:end},2)<cutoff));
output_cpm_filt = output_cpm(idx,:);
output_cpm_filt.Properties.RowNames = output_cpm_filt.Var1;
output_cpm_filt = output_cpm_filt(:,2:end);

%%%% Input Data %%%%
% Specify + load input data files (proteomics)
filepath = "aav3233_Data_file_S1.xlsx";
opts = detectImportOptions(filepath,"Sheet","Table S2");
rfu = readtable(filepath, opts);

% Filter + Process input data
% ID inputs from model
input_id = strcmpi(snm_rxns.module,"input");
input_prot = split(snm_rxns.Rule(input_id),"=>");
input_prot = split(input_prot(:,2)," ");
input_prot = input_prot(:,2);
% convert to gene names
input_genes = cell.empty;
for input = 1:length(input_prot)
    idx = find(strcmpi(snm_species.ID, input_prot(input)));
    gene = split(snm_species.geneName(idx),"; ");   % split genes with multiple names
    for i = 1:length(gene)
        input_genes(end+1) = gene(i);   % appends all gene names (incl. multiples)
    end
end
input_genes = transpose(rmmissing(input_genes));
% filter rfu data for output genes
rfu_idx = NaN(1,length(input_genes));
for input = 1:length(input_genes)
    idx = find(strcmpi(rfu.EntrezGeneSymbol, input_genes(input)));
    if isempty(idx) ~= 1
        rfu_idx(input) = idx(:);
    end
end
input_rfu = rfu(rmmissing(rfu_idx),:);
input_rfu.Properties.RowNames = input_rfu.EntrezGeneSymbol;
input_rfu = input_rfu(:,contains(input_rfu.Properties.VariableNames, "TAVR"));
% extract patients with both input/output data
for var = 1:length(input_rfu.Properties.VariableNames)
    inboth = strcmpi(output_cpm_filt.Properties.VariableNames, input_rfu.Properties.VariableNames(var));
end





% toc

