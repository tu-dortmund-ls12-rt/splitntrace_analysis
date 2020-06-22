source("sample.R")
require(data.table)
require(tikzDevice)

import_nvmain_trace_rw <- function(filename){
    #table <- read.table(filename, skip=1)
    table <- fread(filename, skip=1)
    #Walk through table
    rw <- table$V2
    address <- strtoi(table$V3)
    pc <- as.numeric(table$V4)
    
    return(list(address,pc,rw))
}

do_dyn_plot_log <- function(filename, plotfile, dyn_lower_bnd, dyn_upper_bnd, text_lower_bnd, text_upper_bnd, y_lower_lim, y_upper_lim, lib_names, lib_sections){
    data <- import_nvmain_trace_rw(filename)
#     
    num_libs <- length(lib_names)
    write_width <- 64
    stack_agg <- rep(list(rep(0, dyn_upper_bnd-dyn_lower_bnd)),num_libs)
    
    number_accesses <- length(data[[1]])
    for(i in seq(1,number_accesses)){
        address <- data[[1]][i]
        pc <- data[[2]][i]-0x80000000
        
        if(data[[3]][i]=="W"){
            if(address >= dyn_lower_bnd && address < dyn_upper_bnd){
                if(pc >= text_lower_bnd && pc < text_upper_bnd){
                    stack_offset <- address - dyn_lower_bnd
                    #Identify the library
                    lib <- 1
                    for (x in seq(1,length(lib_sections))){
                        for (pair in seq(1,length(lib_sections[[x]]),2)){
                            if(pc >= lib_sections[[x]][pair]-0x80000000 && pc < lib_sections[[x]][pair+1]-0x80000000){
                                lib <- x
                            }
                        }
                    }
#                     if(lib ==2 ){
#                         print(paste("Access from sqlite to ",address));
#                     }
                    
                    #print(paste("Saving tsack access for lib",lib));
                    for(o in seq(0,63)){
                        stack_agg[[lib]][stack_offset+o] <- stack_agg[[lib]][stack_offset+o]+1
                    }
                    
                }
                else{
                    print("ERROR pc access not to text")
                    q()
                }
            }
        }
    }
#     
    sampling_rate <- 150
    stack_agg_sampled <- rep(list(rep(0, (dyn_upper_bnd-dyn_lower_bnd)/sampling_rate)),num_libs)
    for(i in seq(1,num_libs)){
        stack_agg_sampled[[i]] <- sample_data(stack_agg[[i]],sampling_rate)
    }
    
    colors=rainbow(length(lib_sections))
    
    pdf(paste(plotfile,".pdf",sep=""))
    num_pages <- (dyn_upper_bnd-dyn_lower_bnd)/4096
    plot(0, type="n", xlab="main memory address (bytes)", ylab="write count", main="Stack Plot", log="y", ylim=c(10^y_lower_lim, 10^y_upper_lim), xlim=c(1,(dyn_upper_bnd-dyn_lower_bnd)/sampling_rate), panel.first=c(abline(v=(seq(0,num_pages)*27.3),col=8), abline(h=10^(seq(y_lower_lim, y_upper_lim)), col=8, lty=2) ))
    axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=8) * rep(seq(2,9),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.01)
    axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=1) * rep(seq(1,1),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.02)
    
    for(i in seq(1,num_libs)){
        print(i)
        lines(stack_agg_sampled[[i]], type="l", lwd=2, col=colors[i])
        print(stack_agg_sampled[[i]])
    }
    
    dev.off()
    
    tikz(paste(plotfile,".tikz",sep=""), standAlone=FALSE)
    num_pages <- (dyn_upper_bnd-dyn_lower_bnd)/4096
    plot(0, type="n", xlab="main memory address (bytes)", ylab="write count", main="Stack Plot", log="y", ylim=c(10^y_lower_lim, 10^y_upper_lim), xlim=c(1,(dyn_upper_bnd-dyn_lower_bnd)/sampling_rate), panel.first=c(abline(v=(seq(0,num_pages)*27.3),col=8), abline(h=10^(seq(y_lower_lim, y_upper_lim)), col=8, lty=2) ))
    axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=8) * rep(seq(2,9),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.01)
    axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=1) * rep(seq(1,1),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.02)
    
    for(i in seq(1,num_libs)){
        print(i)
        lines(stack_agg_sampled[[i]], type="l", lwd=2, col=colors[i])
        print(stack_agg_sampled[[i]])
    }
    
    dev.off()
    
#     tikz(paste(plotfile,".tikz",sep=""), standAlone=FALSE)
#     num_pages<-(upper_bnd-lower_bnd)/4096
#     plot(data_agg_sampled, type="l", lwd=2, col=color, xlab="main memory address (bytes)", ylab="write count", main=plotname, log="y", ylim=c(10^y_lower_lim, 10^y_upper_lim), panel.first=c(draw_lib_sections(lib_names,lib_sections,y_lower_lim, y_upper_lim, lower_bnd, upper_bnd)
#     , abline(v=(seq(0,num_pages)*128),col=8)
#     , abline(h=10^(seq(y_lower_lim, y_upper_lim)), col=8, lty=2) ))
#     axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=8) * rep(seq(2,9),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.01)
#     axis(side=2, at=rep((10^(seq(y_lower_lim,y_upper_lim))), each=1) * rep(seq(1,1),(y_upper_lim-y_lower_lim+1)), labels=FALSE, tck=-0.02)
#     dev.off()
}

# draw_lib_sections <- function(lib_names, lib_sections, y_lower_lim, y_upper_lim, lower_bnd, upper_bnd){
#     draw_vec <- c()
#     colors=rainbow(length(lib_sections))
#     for (i in seq(1,length(lib_sections))){
#         for (pair in seq(1,length(lib_sections[[i]]),2)){
#             draw_x_offset <- (lib_sections[[i]][pair]-lower_bnd - 0x80000000)/32
#             draw_x_end <- (lib_sections[[i]][pair+1]-lower_bnd - 0x80000000)/32
#             draw_vec <- c(draw_vec, rect(draw_x_offset,10^y_lower_lim,draw_x_end,10^y_upper_lim, border=NA, col=colors[i]))
#         }
#     }
#     return(draw_vec)
# }
