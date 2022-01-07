
##read otu table
setwd("D://CloudDrive/ownCloud/iDIRECT/result/seasonal_warming/knockout_vulner")

#consider cascade effects
rand.remov1.once<-function(netRaw, rm.num, keystonelist, sp.ra, abundance.weighted=T){
  rm.num2<-ifelse(rm.num > length(keystonelist), length(keystonelist), rm.num)
  id.rm<-sample(keystonelist, rm.num2)
  net.Raw=netRaw #don't want change netRaw
  
  net.new=net.Raw[!names(sp.ra) %in% id.rm, !names(sp.ra) %in% id.rm]   ##remove all the links to these species
  if (nrow(net.new)<2){
    0
  } else {
    sp.ra.new=sp.ra[!names(sp.ra) %in% id.rm]
    
    if (abundance.weighted){
      net.stength= net.new*sp.ra.new
    } else {
      net.stength= net.new
    }
    
    sp.meanInteration<-colMeans(net.stength)
    
    
    while ( length(sp.meanInteration)>1 & min(sp.meanInteration) <=0){
      id.remain<- which(sp.meanInteration>0) 
      net.new=net.new[id.remain,id.remain]
      sp.ra.new=sp.ra.new[id.remain]
      
      if (abundance.weighted){
        net.stength= net.new*sp.ra.new
      } else {
        net.stength= net.new
      }
      
      if (length(net.stength)>1){
        sp.meanInteration<-colMeans(net.stength)
      } else{
        sp.meanInteration<-0
      }
      
    }
    
    remain.percent<-length(sp.ra.new)/length(sp.ra)
    
    remain.percent}
}

#not consider cascade effects
rand.remov1.once_2extinctOnly<-function(netRaw, rm.num, keystonelist, sp.ra, abundance.weighted=T){
  rm.num2<-ifelse(rm.num > length(keystonelist), length(keystonelist), rm.num)
  id.rm<-sample(keystonelist, rm.num2)
  net.Raw=netRaw #don't want change netRaw
  
  net.new=net.Raw[!names(sp.ra) %in% id.rm, !names(sp.ra) %in% id.rm]   ##remove all the links to these species
  if (nrow(net.new)<2){
    0
  } else {
    sp.ra.new=sp.ra[!names(sp.ra) %in% id.rm]
    
    if (abundance.weighted){
      net.stength= net.new*sp.ra.new
    } else {
      net.stength= net.new
    }
    
    sp.meanInteration<-colMeans(net.stength)
    
    id.remain<- which(sp.meanInteration>0) 
    sp.ra.new=sp.ra.new[id.remain]
    
    remain.percent<-length(sp.ra.new)/length(sp.ra)
    
    remain.percent}
}

#rm.p.list=seq(0.05,0.2,by=0.05)
rmsimu1<-function(netRaw, rm.p.list, keystonelist,sp.ra, abundance.weighted=T,nperm=100){
  t(sapply(rm.p.list,function(x){
    remains=sapply(1:nperm,function(i){
      rand.remov1.once(netRaw=netRaw, rm.num=x, keystonelist=keystonelist, sp.ra=sp.ra, abundance.weighted=abundance.weighted)
    })
    remain.mean=mean(remains)
    remain.sd=sd(remains)
    remain.se=sd(remains)/(nperm^0.5)
    result<-c(remain.mean,remain.sd,remain.se)
    names(result)<-c("remain.mean","remain.sd","remain.se")
    result
  }))
}
rmsimu1_2extinctOnly<-function(netRaw, rm.p.list, keystonelist,sp.ra, abundance.weighted=T,nperm=100){
  t(sapply(rm.p.list,function(x){
    remains=sapply(1:nperm,function(i){
      rand.remov1.once_2extinctOnly(netRaw=netRaw, rm.num=x, keystonelist=keystonelist, sp.ra=sp.ra, abundance.weighted=abundance.weighted)
    })
    remain.mean=mean(remains)
    remain.sd=sd(remains)
    remain.se=sd(remains)/(nperm^0.5)
    result<-c(remain.mean,remain.sd,remain.se)
    names(result)<-c("remain.mean","remain.sd","remain.se")
    result
  }))
}



#####################random deletion######################

#consider cascade effects: removed species will further influence the remaining nodes

rand.remov2.once<-function(netRaw, rm.percent, sp.ra, abundance.weighted=T){
  id.rm<-sample(1:nrow(netRaw), round(nrow(netRaw)*rm.percent))
  net.Raw=netRaw #don't want change netRaw
  
  net.new=net.Raw[-id.rm, -id.rm]   ##remove all the links to these species
  if (nrow(net.new)<2){
    0
  } else {
    sp.ra.new=sp.ra[-id.rm]
    
    if (abundance.weighted){
      net.stength= net.new*sp.ra.new
    } else {
      net.stength= net.new
    }
    
    sp.meanInteration<-colMeans(net.stength)
    
    
    while ( length(sp.meanInteration)>1 & min(sp.meanInteration) <=0){
      id.remain<- which(sp.meanInteration>0) 
      net.new=net.new[id.remain,id.remain]
      sp.ra.new=sp.ra.new[id.remain]
      
      if (abundance.weighted){
        net.stength= net.new*sp.ra.new
      } else {
        net.stength= net.new
      }
      
      if (length(net.stength)>1){
        sp.meanInteration<-colMeans(net.stength)
      } else{
        sp.meanInteration<-0
      }
      
    }
    
    remain.percent<-length(sp.ra.new)/length(sp.ra)
    
    remain.percent}
}

rand.remov2.once_2extinctOnly<-function(netRaw, rm.percent, sp.ra, abundance.weighted=T){
  id.rm<-sample(1:nrow(netRaw), round(nrow(netRaw)*rm.percent))
  net.Raw=netRaw #don't want change netRaw
  
  net.new=net.Raw[-id.rm, -id.rm]   ##remove all the links to these species
  if (nrow(net.new)<2){
    0
  } else {
    sp.ra.new=sp.ra[-id.rm]
    
    if (abundance.weighted){
      net.stength= net.new*sp.ra.new
    } else {
      net.stength= net.new
    }
    
    sp.meanInteration<-colMeans(net.stength)
    id.remain<- which(sp.meanInteration>0) 
    sp.ra.new=sp.ra.new[id.remain]
    remain.percent<-length(sp.ra.new)/length(sp.ra)
    remain.percent}
}


#rm.p.list=seq(0.05,0.2,by=0.05)
rmsimu<-function(netRaw, rm.p.list, sp.ra, abundance.weighted=T,nperm=100){
  t(sapply(rm.p.list,function(x){
    remains=sapply(1:nperm,function(i){
      rand.remov2.once(netRaw=netRaw, rm.percent=x, sp.ra=sp.ra, abundance.weighted=abundance.weighted)
    })
    remain.mean=mean(remains)
    remain.sd=sd(remains)
    remain.se=sd(remains)/(nperm^0.5)
    result<-c(remain.mean,remain.sd,remain.se)
    names(result)<-c("remain.mean","remain.sd","remain.se")
    result
  }))
}
rmsimu_2extinctOnly<-function(netRaw, rm.p.list, sp.ra, abundance.weighted=T,nperm=100){
  t(sapply(rm.p.list,function(x){
    remains=sapply(1:nperm,function(i){
      rand.remov2.once_2extinctOnly(netRaw=netRaw, rm.percent=x, sp.ra=sp.ra, abundance.weighted=abundance.weighted)
    })
    remain.mean=mean(remains)
    remain.sd=sd(remains)
    remain.se=sd(remains)/(nperm^0.5)
    result<-c(remain.mean,remain.sd,remain.se)
    names(result)<-c("remain.mean","remain.sd","remain.se")
    result
  }))
}

corrFile="16S_OK5Y_control_spearman corr_full.txt"
otuFile="16S_OK5Y_control_spearman MV Estimated.txt"
modFile="16S_OK5Y_control_spearman 0.71 fast_greedy.out"
netTag="control_spearman"

cormatrix<-read.csv(corrFile,sep="\t",header = F)
otutab<-read.csv(otuFile,sep="\t",header = F,row.names = 1)

otutab[is.na(otutab)]<-0
comm<-t(otutab)
comm<-comm/rowSums(comm)   

sp.ra<-colMeans(comm)  #relative abundance of each species


row.names(cormatrix)<-colnames(cormatrix)<-colnames(comm)


cormatrix2<-cormatrix*(abs(cormatrix)>=0.66)  #only keep links above the cutoff point
cormatrix2[is.na(cormatrix2)]<-0
diag(cormatrix2)<-0    #no links for self-self    
sum(abs(cormatrix2)>0)/2  #this should be the number of links. 

sum(colSums(abs(cormatrix2))>0)  #?? species have at least one linkage with others.

network.raw<-cormatrix2[colSums(abs(cormatrix2))>0,colSums(abs(cormatrix2))>0]
sp.ra2<-sp.ra[colSums(abs(cormatrix2))>0]
sum(row.names(network.raw)==names(sp.ra2))  #check if matched

#input network matrix, percentage of randomly removed species, and ra of all species
#return the proportion of species remained

node.attri<-read.csv(modFile,sep="\t",skip = 2,row.names = 1)
module.hub<-as.character(node.attri$ID[node.attri$Zi > 2.5 & node.attri$Pi <= 0.62])
length(module.hub)


Weighted.simu<-rmsimu1(netRaw=network.raw, rm.p.list=1:length(module.hub),keystonelist=module.hub, sp.ra=sp.ra2, abundance.weighted=T,nperm=100)
Unweighted.simu<-rmsimu1(netRaw=network.raw, rm.p.list=1:length(module.hub), keystonelist=module.hub, sp.ra=sp.ra2, abundance.weighted=F,nperm=100)

Weighted.simu_2extinctOnly<-rmsimu1_2extinctOnly(netRaw=network.raw, rm.p.list=1:length(module.hub),keystonelist=module.hub, sp.ra=sp.ra2, abundance.weighted=T,nperm=100)
Unweighted.simu_2extinctOnly<-rmsimu1_2extinctOnly(netRaw=network.raw, rm.p.list=1:length(module.hub), keystonelist=module.hub, sp.ra=sp.ra2, abundance.weighted=F,nperm=100)



dat1<-data.frame(Number.hub.removed=rep(1:length(module.hub),4),rbind(Weighted.simu,Unweighted.simu,Weighted.simu_2extinctOnly,Unweighted.simu_2extinctOnly),
                 weighted=rep(c("weighted","unweighted","weighted","unweighted"),each=length(module.hub)),consider_cascade=rep(c("Yes","No"),each=2*length(module.hub)),
                 network=rep(netTag,4*length(module.hub)))

currentdat_target<-dat1
currentdat_target<-rbind(dat1,currentdat_target)
write.csv(currentdat_target,"simuresult_target_deletion.csv")



Weighted.simu2<-rmsimu(netRaw=network.raw, rm.p.list=seq(0.05,1,by=0.05), sp.ra=sp.ra2, abundance.weighted=T,nperm=100)
Unweighted.simu2<-rmsimu(netRaw=network.raw, rm.p.list=seq(0.05,1,by=0.05), sp.ra=sp.ra2, abundance.weighted=F,nperm=100)

Weighted.simu2_2extinctOnly<-rmsimu_2extinctOnly(netRaw=network.raw, rm.p.list=seq(0.05,1,by=0.05), sp.ra=sp.ra2, abundance.weighted=T,nperm=100)
Unweighted.simu2_2extinctOnly<-rmsimu_2extinctOnly(netRaw=network.raw, rm.p.list=seq(0.05,1,by=0.05), sp.ra=sp.ra2, abundance.weighted=F,nperm=100)


dat2<-data.frame(Proportion.removed=rep(seq(0.05,1,by=0.05),4),rbind(Weighted.simu2,Unweighted.simu2,Weighted.simu2_2extinctOnly,Unweighted.simu2_2extinctOnly),
                 weighted=rep(c("weighted","unweighted","weighted","unweighted"),each=20),
                 consider_cascade=rep(c("Yes","No"),each=40),
                 network=rep(netTag,80))

#random deletion
currentdat<-dat2
currentdat<-rbind(dat2,currentdat)
write.csv(currentdat,"simuresult_random_deletion.csv")


###simulation, write out simulated networks###
##at 40% and 60% removal level##


##example plot
##library(ggplot2)

#weighted result

#currentdat<-currentdat[currentdat$network %in% c("warming_pearson_idirect","control_pearson_idirect"),]

#currentdat$consider_cascade=factor(currentdat$consider_cascade,levels = c("Yes","No"),labels=c("with_cascade","not_cascade"))
#ggplot(currentdat[currentdat$weighted=="weighted",], aes(x=Proportion.removed, y=remain.mean, group=network, color=network)) + 
#  geom_line()+
#  geom_pointrange(aes(ymin=remain.mean-remain.sd, ymax=remain.mean+remain.sd),size=0.2)+
#  xlab("Proportion of species removed")+
#  ylab("Proportion of species remained")+
#  theme_light()+
#  facet_wrap(~consider_cascade, ncol=2)




