#################################################################
##Quiescence score validation on bulk and scRNA-seq datasets
#################################################################


#The following are validation datasets:
#GSE152699 
#GSE131594 
#GSE83142 
#GSE75367 
#GSE137912 
#GSE93991 
#GSE114012 

#Load required packages:
library(GSVA)
library(dplyr)
library(ggplot2)
library(plotROC)
library(RColorBrewer)

#Load quiescence genes:
setwd("~/Documents/GitHub/CancerDormancy/Data/DormancyGeneList")
load("downregulated_common.RData")
load("downregulated_common_ENSG.RData")
load("upregulated_common.RData")
load("upregulated_common_ENSG.RData")

#############################################
##Calculate quiescence scores for all samples
#############################################


##############
#GSE131594

#Load expression data
expr.data <- read.table(file = "GSE131594_RNAseq_DormantCells_FPKM.txt", sep = "\t", header = TRUE) #Can be obtained from GEO using accession code GSE131594
expr.data <- expr.data %>% group_by(gene.symbol) %>% mutate_each(funs(mean)) %>% distinct
expr.data <- data.frame(expr.data)
rownames(expr.data) <- expr.data$gene.symbol
expr.data$gene.symbol <- NULL
expr.data$gene_id <- NULL
expr.data[1:10,1:10]
X <- as.matrix(expr.data)
X <- log2(X+1)
#Add annotation information
Samples <- colnames(expr.data)
binary_groups <- c(1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0,1,1,1,1,0,0,0,0)
annotation <- data.frame(Samples, binary_groups)
#Quiescence scoring
gene_lists <- list(upregulated_common, downregulated_common)
es.dif <- gsva(X, gene_lists, method = "zscore", verbose = FALSE, parallel.sz=1)
es.dif <- t(es.dif)
es.dif <- data.frame(es.dif)
es.dif$GSVA_score <- es.dif$X1 - es.dif$X2
#Save the result:
z_score <- es.dif$GSVA_score
z_score_common <- data.frame(z_score, binary_groups)
rownames(z_score_common) <- annotation$Samples
setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Results/")
#save(z_score_common, file = "GSE131594_QS.RData")



##############
#GSE114012

#Load expression data
setwd("~/Documents/GitHub/CancerDormancy/Data/NormalisedRNAseqDatasets/")
load("GSE114012_TPM_expression.RData")
load("GSE114012_sample_annotations.RData")
X <- as.matrix(TPM_expression)
X <- log2(X+1)
#Quiescence scoring
gene_lists <- list(upregulated_common, downregulated_common)
es.dif <- gsva(X, gene_lists, method = "zscore", verbose = FALSE, parallel.sz=1)
es.dif <- t(es.dif)
es.dif <- data.frame(es.dif)
es.dif$GSVA_score <- es.dif$X1 - es.dif$X2
groups <- coldata$Group
es.dif$Group <- groups
es.dif$quiescence.group <- sapply(es.dif$Group, function(x)
  ifelse(x %in% c("Quiescent"),1,0))
PatientID <- rownames(es.dif)
z_score <- es.dif$GSVA_score
binary_group <- es.dif$quiescence.group
z_scores <- data.frame(z_score, binary_group)
rownames(z_scores) <- PatientID
setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Results/")
#save(z_scores, file = "GSE114012_QS.RData")






##############
#GSE137912

#Load expression data
X <- read.csv("GSE137912_logcounts.csv",header = TRUE) #Data cam be obtained from GEO using accession code GSE137912
X <- as.matrix(normalised_imputed_data)
all_genes <- as.character(X$X)
X$X <- NULL
rownames(X) <- all_genes
##Load annotation data
annotation <- read.csv("GSE137912_cell.annotation.csv",header = TRUE) #Data can be obtained from GEO using accession code GSE137912
annotation_H358 <- annotation[annotation$Line %in% "H358" & annotation$Hours %in% c(0,24),]
##Select an expression matrix with the desired samples
samples_H358 <- as.character(annotation_H358$X)
H358_expression <- X[,colnames(X) %in% samples_H358]
##Quiescence Score calculation
gene_lists <- list(upregulated_common, downregulated_common)
H358_expression <- as.matrix(H358_expression)
es.dif <- gsva(H358_expression, gene_lists, method = "zscore", verbose = FALSE, parallel.sz=1)
es.dif <- t(es.dif)
es.dif <- data.frame(es.dif)
es.dif$GSVA_score <- es.dif$X1 - es.dif$X2
#Now look at the differences in scores across the two cell types
es.dif$group <- annotation_H358$Hours
es.dif$group[es.dif$group == 24] <- 1
Score <- es.dif$GSVA_score
Patient_ID <- rownames(es.dif)
binary_group <- es.dif$group
z_scores <- data.frame(Score, binary_group)
rownames(z_scores) <- Patient_ID
setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Results/")
#save(z_scores, file = "GSE137912_QS.RData")




##############
#GSE152699

#Load expression data
expr.data <- read.table(file = "Data/GSE152699_Cells_fpkm.txt", sep = "\t", header = TRUE) #Data can be downloaded from GEO using accession code GSE152699
expr.data <- expr.data %>% group_by(Name) %>% mutate_each(funs(mean)) %>% distinct
expr.data <- data.frame(expr.data)
rownames(expr.data) <- expr.data$Name
expr.data$Name <- NULL
expr.data[1:1,1:10]
X <- as.matrix(expr.data)
X <- log2(X+1)
#Add annotation information
Samples <- colnames(expr.data)
binary_groups <- c(0,0,0,0,0,0,1,1,1,1,1,1)
annotation <- data.frame(Samples, binary_groups)
#Quiescence scoring
gene_lists <- list(upregulated_common, downregulated_common)
es.dif <- gsva(X, gene_lists, method = "zscore", verbose = FALSE, parallel.sz=1)
es.dif <- t(es.dif)
es.dif <- data.frame(es.dif)
es.dif$GSVA_score <- es.dif$X1 - es.dif$X2
#Save the result:
z_score <- es.dif$GSVA_score
z_score_common <- data.frame(z_score, binary_groups)
rownames(z_score_common) <- annotation$Samples
setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Results/")
#save(z_score_common, file = "GSE152699_QS.RData")





##############
#GSE75367

#Load expression data
setwd("~/Documents/GitHub/CancerDormancy/Data/NormalisedScRNAseqDatasets/")
load("GSE75367_normalised_counts.RData")
load("GSE75367_annotation.RData")
X <- as.matrix(normalised_counts)
#Quiescence scoring
gene_lists <- list(upregulated_common, downregulated_common)
es.dif <- gsva(X, gene_lists, method = "zscore", verbose = FALSE, parallel.sz=1)
es.dif <- t(es.dif)
es.dif <- data.frame(es.dif)
es.dif$GSVA_score <- es.dif$X1 - es.dif$X2
#Now look at the differences in scores across the two cell types
selected_names <- rownames(es.dif)
anno <- anno[rownames(anno) %in% selected_names,]
es.dif$Group <- anno
es.dif$quiescence.group <- sapply(es.dif$Group, function(x)
  ifelse(x %in% c("low"),1,0))
#Save quiescence scores:
z_scores <- es.dif$GSVA_score
binary_group <- es.dif$quiescence.group
z_scores <- data.frame(z_scores, binary_group)
rownames(z_scores) <- rownames(es.dif)
setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Results/")
#save(z_scores, file = "GSE75367_QS.RData")




##############
#GSE83142

#Load expression data
setwd("~/Documents/GitHub/CancerDormancy/Data/NormalisedScRNAseqDatasets/")
load("GSE83142_normalised_counts.RData")
X <- as.matrix(normalised_counts)
#Quiescence scoring
gene_lists <- list(upregulated_common_ENSG, downregulated_common_ENSG)
es.dif <- gsva(X, gene_lists, method = "zscore", verbose = FALSE, parallel.sz=1)
es.dif <- t(es.dif)
es.dif <- data.frame(es.dif)
es.dif$GSVA_score <- es.dif$X1 - es.dif$X2
#Now look at the differences in scores across the two cell types
groups <- c(rep(0,34), rep(1,14))
es.dif$Group <- groups
es.dif$Score <- es.dif$GSVA_score
patient_ID <- rownames(es.dif)
Combined_z_score <- es.dif$Score
binary_group <- es.dif$Group
z_scores <- data.frame(Combined_z_score, binary_group)
rownames(z_scores) <- patient_ID
setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Results/")
#save(z_scores, file = "GSE83142_QS.RData")





##############
#GSE93991
expr.data <- read.table(file = "GSE93991_RNA-seq_Expression_Data.txt", sep = "\t", header = FALSE) #data can be downloaded from GEO using accession code GSE93991
rownames(expr.data) <- expr.data$V1
expr.data$V1 <- NULL
#Expression data starts from V10
expr.data$V2 <- NULL
expr.data$V3 <- NULL
expr.data$V4 <- NULL
expr.data$V5 <- NULL
expr.data$V6 <- NULL
expr.data$V7 <- NULL
expr.data$V8 <- NULL
expr.data$V9 <- NULL
#Add colnames:
Sample <- c("Quiescence1", "Quiescence2", "Quiescence3", "Proliferation1", "Quiescence4", "Proliferation2", "Quiescence5", "Proliferation3","Proliferation4", "Proliferation5", "Proliferation6", "proliferation7", "Proliferation8", "Proliferation9", "Quiescence6" )
colnames(expr.data) <- Sample
X <- as.matrix(expr.data)
X <- log2(X +1)
#Quiescence scoring
gene_lists <- list(upregulated_common_ENSG, downregulated_common_ENSG)
es.dif <- gsva(X, gene_lists, method = "zscore", verbose = FALSE, parallel.sz=1)
es.dif <- t(es.dif)
es.dif <- data.frame(es.dif)
es.dif$GSVA_score <- es.dif$X1 - es.dif$X2
#Now look at the differences in scores across the two cell types
binary_groups <- c(1,1,1,0,1,0,1,0,0,0,0,0,0,0,1)
z_score <- es.dif$GSVA_score
z_score_common <- data.frame(z_score, binary_groups)
rownames(z_score_common) <- Sample
setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Results/")
#save(z_score_common, file = "GSE93991_QS.RData")











#################################################################################
#########ROC curve using quiescence scores for all validation datasets
#################################################################################


##########################################################################
#Load and combine z-score and binary group information for all 7 studies:

setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Results/")
#GSE152699
load("GSE152699_QS.RData")
GSE152699 <- z_score_common
rm(z_score_common)
GSE152699$"Combined z-score" <- GSE152699$z_score
GSE152699$z_score <- NULL
GSE152699$Dataset <- "GSE152699"
#GSE131594
load("GSE131594_QS.RData")
GSE131594 <- z_score_common
rm(z_score_common)
GSE131594$"Combined z-score" <- GSE131594$z_score
GSE131594$z_score <- NULL
GSE131594$Dataset <- "GSE131594"
#GSE83142
load("GSE83142_QS.RData")
GSE83142 <- z_scores
rm(z_scores)
GSE83142$"Combined z-score" <- GSE83142$Combined_z_score
GSE83142$Combined_z_score <- NULL
GSE83142$Dataset <- "GSE83142"
GSE83142$binary_groups <- GSE83142$binary_group
GSE83142$binary_group <- NULL
#GSE75367
load("GSE75367_QS.RData")
GSE75367 <- z_scores
rm(z_scores)
GSE75367$"Combined z-score" <- GSE75367$z_scores
GSE75367$z_scores <- NULL
GSE75367$Dataset <- "GSE75367"
GSE75367$binary_groups <- GSE75367$binary_group
GSE75367$binary_group <- NULL
#GSE137912
load("GSE137912_QS.RData")
GSE137912 <- z_scores
rm(z_scores)
GSE137912$"Combined z-score" <- GSE137912$Score
GSE137912$Score <- NULL
GSE137912$Dataset <- "GSE137912"
GSE137912$binary_groups <- GSE137912$binary_group
GSE137912$binary_group <- NULL
#GSE93991
load("GSE93991_QS.RData")
GSE93991 <- z_score_common
rm(z_score_common)
GSE93991$"Combined z-score" <- GSE93991$z_score
GSE93991$z_score <- NULL
GSE93991$Dataset <- "GSE93991"
#GSE114012 
load("GSE114012_QS.RData")
GSE114012 <- z_scores
rm(z_scores)
GSE114012$"Combined z-score" <- GSE114012$z_score
GSE114012$z_score <- NULL
GSE114012$Dataset <- "GSE114012"
GSE114012$binary_groups <- GSE114012$binary_group
GSE114012$binary_group <- NULL




#####################################
#Merge the scores for the 5 datasets:
#####################################
GSE114012 <- GSE114012[,order(colnames(GSE114012))]
GSE131594 <- GSE131594[,order(colnames(GSE131594))]
GSE137912 <- GSE137912[,order(colnames(GSE137912))]
GSE152699 <- GSE152699[,order(colnames(GSE152699))]
GSE75367 <- GSE75367[,order(colnames(GSE75367))]
GSE83142 <- GSE83142[,order(colnames(GSE83142))]
GSE93991 <- GSE93991[,order(colnames(GSE93991))]
merged_data <- rbind(GSE114012,GSE131594,GSE137912,GSE152699,GSE75367,GSE83142,GSE93991)



#####################
####################

myCol <- brewer.pal(7, "Spectral")
setwd("~/Documents/GitHub/CancerDormancy/QuiescenceScoreValidation/Figures/")
basicplot <- ggplot(merged_data, aes(d = binary_groups, m = `Combined z-score`, color = Dataset)) + geom_roc(n.cuts = 10, labels = FALSE) + annotate("text", x = .8, y = .14,
label = "GSE114012 AUC = 0.766\nGSE131594 AUC = 0.965\nGSE137912 AUC = 0.986\nGSE152699 AUC = 1.000\nGSE75367 AUC = 0.928\nGSE83142 AUC = 0.922\nGSE93991 AUC = 0.815")
pdf("QuiescenceScoreValidation_ROC.pdf",height = 5, width = 7)
basicplot + labs(x = "False positive fraction", y = "True positive fraction") + theme_classic() +
  theme(axis.text.x = element_text(color = "grey20",face = "plain",size = 12,family = "sans"),
        axis.text.y = element_text(color = "grey20",face = "plain",size = 12,family = "sans"),  
        axis.title.x = element_text(color = "grey20",face = "plain",size = 12,family = "sans"),
        axis.title.y = element_text(color = "grey20", face = "plain",size = 12,family = "sans"),
        legend.text = element_text(colour = "grey20",face = "plain",size = 12,family = "sans")) + scale_color_manual(values = myCol)
dev.off()
#AUC calculations
AUC <- data.frame(calc_auc(basicplot))
AUC








