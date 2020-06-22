source("import_nvmain_trace.R")
source("aggregate_accesses.R")
source("sample.R")
require(tikzDevice)

do_plot_log <- function(filename, plotname, plotfile, lower_bnd, upper_bnd, color, y_lower_lim, y_upper_lim, lib_names, lib_sections){
    print(paste("Plotting",plotname))
    data <- import_nvmain_trace_rw(filename,lower_bnd,upper_bnd)
    print(paste("Length:",length(data)))
    data_agg <- aggregate_accesses(data,64,lower_bnd,upper_bnd)
    print(paste("Mean",mean(data_agg)))
    print(paste("Max",max(data_agg)))
    rm(data)
    gc()
    data_agg_sampled <- sample_data(data_agg,32)
    rm(data_agg)
    gc()
    
    colors=rainbow(length(lib_sections))
    
    pdf(paste(plotfile,".pdf",sep=""))
    num_pages<-(upper_bnd-lower_bnd)/4096
    plot(data_agg_sampled, type="l", lwd=2, col=color, xlab="main memory address (bytes)", ylab="write count", main=plotname, log="y", ylim=c(10^y_lower_lim, 10^y_upper_lim), panel.first=c(draw_lib_sections(lib_names,lib_sections,y_lower_lim, y_upper_lim, lower_bnd, upper_bnd)
    #, abline(v=(seq(0,num_pages)*128),col=8)
    , abline(h=10^(seq(y_lower_lim, y_upper_lim)), col=8, lty=2) ))
    axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=8) * rep(seq(2,9),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.01)
    axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=1) * rep(seq(1,1),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.02)
    dev.off()
    
    pdf(paste(plotfile,"_legend.pdf",sep=""))
    plot(NULL,xaxt='n',yaxt='n',xlab="",ylab="",xlim=0:1,ylim=0:1,bty='n')
    legend("topleft", legend=lib_names, col=colors,pch=16, pt.cex=3, cex=1, bty='n')
    dev.off()
    
    tikz(paste(plotfile,".tikz",sep=""), standAlone=FALSE)
    num_pages<-(upper_bnd-lower_bnd)/4096
    plot(data_agg_sampled, type="l", lwd=2, col=color, xlab="main memory address (bytes)", ylab="write count", main=plotname, log="y", ylim=c(10^y_lower_lim, 10^y_upper_lim), panel.first=c(draw_lib_sections(lib_names,lib_sections,y_lower_lim, y_upper_lim, lower_bnd, upper_bnd)
    #, abline(v=(seq(0,num_pages)*128),col=8)
    , abline(h=10^(seq(y_lower_lim, y_upper_lim)), col=8, lty=2) ))
    axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=8) * rep(seq(2,9),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.01)
    axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=1) * rep(seq(1,1),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.02)
    dev.off()
    
    tikz(paste(plotfile,"_legend.tikz",sep=""), standAlone=FALSE)
    plot(NULL,xaxt='n',yaxt='n',xlab="",ylab="",xlim=0:1,ylim=0:1,bty='n')
    legend("topleft", legend=lib_names, col=colors,pch=16, pt.cex=3, cex=1, bty='n')
    dev.off()
    
    rm(data_agg_sampled)
    gc()
}

draw_lib_sections <- function(lib_names, lib_sections, y_lower_lim, y_upper_lim, lower_bnd, upper_bnd){
    draw_vec <- c()
    colors=rainbow(length(lib_sections))
    for (i in seq(1,length(lib_sections))){
        for (pair in seq(1,length(lib_sections[[i]]),2)){
            draw_x_offset <- (lib_sections[[i]][pair]-lower_bnd - 0x80000000)/32
            draw_x_end <- (lib_sections[[i]][pair+1]-lower_bnd - 0x80000000)/32
            draw_vec <- c(draw_vec, rect(draw_x_offset,10^y_lower_lim,draw_x_end,10^y_upper_lim, border=NA, col=colors[i]))
        }
    }
    return(draw_vec)
}
