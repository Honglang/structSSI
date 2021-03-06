  # This function implements the Adaptive GBH procedure, which really
  # is only a slight modification of the Oracle GBH procedure: You
  # provide estimates of pi\_{0,g}, the proportion of true null hypotheses
  # in each group.
  #
  # Input: 1) group.index - [vector with integers 1 ... # groups] - A vector mapping hypotheses to the group that
  # they are part of. For example, if H1 and H3 are in group 1 and H2 is group 2
  # the input should be c(1, 2, 1)
  # 2) unadjp- [numeric vector] The vector of unadjusted p-values, where the i^th p-value
  # corresponds to the i^th hypothesis (this is so that it works well with
  # the groups index function above). If the vector is labeled, then the labels will
  # be used in the output.
  # 3) method - [ char string ] - A specification of which method of pi0_g estimation to use. Use
  # 'tail p' to refer to Storey's tail-p method, 'lsl to refer to the
  # least slope method (BH 2000)), and 'tst' to refer to the two-step
  # procedure method (Yekutieli, Kreiger, and Hochberg). If the user
  # already has estimates of the proportion of null hypotheses in
  # each group, then the Oracle GBH procedure can be applied.
  # 4) alpha - [numeric, usually 0.05] The level at which the GBH procedure will be performed.
  #
  # Output: 1) table - A data frame containing information from each
  # step of the Group Benjamini-Hochberg procedure. We are able to see
  # the sorted raw p-values and the hypothesis index from the p-values vector
  # that each raw p-value corresponds to in the first two columns. In
  # the second two columns, we see the sorted weighted p-values generated by
  # the procedure along with the indices of the hypotheses that those
  # weighted p-values correspond to. In the final column, we see the
  # finalized Group Benjamini-Hochberg adjusted p-values. The hypotheses
  # that each of these adjusted p-values corresponds to is the same
  # as the weighted p-values hypothesis index (we can do this because
  # the adjustment from weighted p-values to GBH p-values does not
  # change the ordering of the p-values.)
  # 2) pi0 - The estimates of pi0 for the groups 1...n,
  # where where the entry in the i^th index is the estimate
  # of the proportion of null hypotheses in the group labeled
  # 'i' in the 'gropus' vector in the input.

Adaptive.GBH.adjp <- function(unadjp, group.index, method, alpha = 0.05, lambda = 0.5){
    method <- tolower(method)
    method <- match.arg(method, c("storey", "lsl", "tst"))
    nGroups <- length(unique(group.index))
    pi0.groups <- vector(length = nGroups)
    for(i in 1:nGroups){
        if(method == 'storey'){
            pi0.groups[i] <- pi0.tail.p(lambda, unadjp[which(group.index == i)])
        } else if(method == 'lsl'){
            pi0.groups[i] <- pi0.lsl(unadjp[which(group.index == i)])
        } else if(method == 'tst'){
            pi0.groups[i] <- pi0.tst(unadjp[which(group.index == i)], alpha)
        }
    }
    names(pi0.groups) <- paste("Group", c(1:nGroups))
    resultTable <- Oracle.GBH.adjp(unadjp, group.index, pi0.groups)
    GBH.result <- list(unadjusted.p.values = resultTable$unadjusted.p.values,
                       GBH.adjusted.p.values = resultTable$GBH.adjusted.p.values,
                       pi0 = pi0.groups)
    return(GBH.result)
}
