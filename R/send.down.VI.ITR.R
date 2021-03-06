#' Sends testing data down a tree to assess the performance of the tree. This is used inside
#' the variable importance function. 
#' 
#' @param dat.new the new data set being sent down the tree. Required input. 
#' @param tree constructed tree.
#' @param col.y the response variable. Required input. 
#' @param col.trt the treatment indicator.  Must be binary. Required input.
#' @param col.prtx the probability of being assigned to treatment group. Required input. 
#' @param ctg identifies the categorical input columns.  Defaults to NA.  Not available yet. 
#' @param n0 minimum number of treatment/control observations needed in a split to call a node terminal. Defaults to 5. 
#' @return summary of tree performance
#' @export



send.down.VI.ITR <- function(dat.new, tre, col.y, col.trt, col.prtx, ctg=NA, n0=5, revise.tree=T,depth=1)
{
  #select data from bootstrap samples (coming from random forest / variable importance functions)
  node.dat <- rep(0, nrow(dat.new))   		
  cut.point <- as.vector(tre$cut.2)   
  cut.direct <- as.vector(tre$cut.1)
  split.var <- as.numeric(as.vector(tre$var))
  y <- dat.new[, col.y]    
  trt <- dat.new[, col.trt]
  prtx <- dat.new[,col.prtx]
  nd <- dim(tre)[1]
  
  tre0 <- tre # bootstrap generated tree
  tre0$n.test <- rep(NA, nrow(tre))
  tre0$score.test <- rep(NA, nrow(tre)) # 
  i <- 1
  zz <- rep(0,nrow(dat.new))
  # this extracts tree information for comparison with OOB sample
  while (i <= nrow(tre0)){
    node.i <- tre0$node[i]
    in.node <- (node.dat == node.i)
    y0 <- y[in.node]
    trt0 <- trt[in.node]
    prtx0 <- prtx[in.node]
    dat0 <- data.frame(y=y0, trt=trt0, prtx=prtx0)
    n.0 <- length(y0)
    tre0$n.test[i] <- n.0
    t2 <- NA    
    if (!is.na(split.var[i])){
      x.split <- dat.new[,split.var[i]]; 
      cut <- cut.point[i]
      cut.d <- cut.direct[i]
      if (!is.element(split.var[i], ctg)) { 
        cut1 <- as.numeric(cut)    
        l.nd <- node.dat[in.node & x.split <= cut1] 
        r.nd <- node.dat[in.node & x.split > cut1]
        z <- sign(x.split[in.node] <= cut1)
        node.dat[in.node & x.split <= cut1] <- paste(l.nd, 1, sep="")  
        node.dat[in.node & x.split >  cut1] <- paste(r.nd, 2, sep="")
        if(i <= depth){
          if(cut.d=="l") {
            zz[in.node & x.split <= cut1] <- 1
          } else {
            zz[in.node & x.split > cut1] <- 1
          }
        }
      }
      else {
        cut1 <- unlist(strsplit(as.character(cut), split=" "))  
        l.nd <- node.dat[in.node & is.element(x.split, cut1)] 
        r.nd <- node.dat[in.node & !is.element(x.split, cut1)]   
        z <- sign(is.element(x.split[in.node], cut1))  
        node.dat[in.node & is.element(x.split, cut1)] <- paste(l.nd, 1, sep="")    
        node.dat[in.node & !is.element(x.split, cut1)] <- paste(r.nd, 2, sep="")  	             
      }
      t2 <- itrtest2(dat0, z, n0=n0)
      tre0$score.test[i] <- t2
    }
    if (is.na(t2) && revise.tree) {
      node.rm <-  de(node.i, tre0)
      tre0 <- tre0[!is.element(tre0$node, node.rm), ]
      tre0[tre0$node==node.i, c("var", "vname", "cut.1", "cut.2", "score")] <- NA
    }  
    i <- i+1
  }
  out  <- list(tre0=tre0,score=itrtest2(dat.new, zz, n0=n0))
  return(out)
}