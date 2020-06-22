source("import_nvmain_trace.R")
source("aggregate_accesses.R")
source("sample.R")

estimate_wear_potential <- function(filename, lower_bnd, upper_bnd, wl_regions){
    data <- import_nvmain_trace(filename,lower_bnd,upper_bnd)
    print(paste("Length:",length(data)))
    data_agg <- aggregate_accesses(data,64,lower_bnd,upper_bnd)
    print(paste("Mean",mean(data_agg)))
    print(paste("Max",max(data_agg)))
    rm(data)
    gc()
    
    pb_dist <- sample_data(data_agg, 4096)
    
    ideal_base <- mean(data_agg) / max(data_agg)
    pb_base <- mean(pb_dist) / max(pb_dist)
    print(paste("Ideal Base is",ideal_base));
    print(paste("PB Base is",pb_base));
    
    #replace leveld daza with ideal WL result
    for(i in seq(1,length(wl_regions),2)){
        wl_lower_bnd <- wl_regions[i] - 0x80000000 - (wl_regions[i] %% 4096)
        wl_upper_bnd <- wl_regions[i+1] - 0x80000000
        if(wl_upper_bnd %% 4096 == 0){
            wl_upper_bnd <- wl_upper_bnd + (4096 - (wl_upper_bnd %% 4096)) 
        }
        
        if(wl_lower_bnd < lower_bnd && wl_upper_bnd > lower_bnd){
            wl_lower_bnd=lower_bnd;
        }
        if(wl_upper_bnd > upper_bnd && wl_lower_bnd < upper_bnd){
            wl_upper_bnd=upper_bnd;
        }
        
        if(wl_lower_bnd >= lower_bnd && wl_upper_bnd <= upper_bnd){
            ideal_wl_result <- mean(data_agg[seq(wl_lower_bnd-lower_bnd,wl_upper_bnd-lower_bnd)])
            data_agg[seq(wl_lower_bnd-lower_bnd,wl_upper_bnd-lower_bnd)]=ideal_wl_result
            pb_wl_result <- mean(pb_dist[seq((wl_lower_bnd-lower_bnd)/4096,(wl_upper_bnd-lower_bnd)/4096)])
            pb_dist[seq((wl_lower_bnd-lower_bnd)/4096,(wl_upper_bnd-lower_bnd)/4096)]=pb_wl_result
        }
    }
    
    ideal_leveled <- mean(data_agg)/max(data_agg)
    pb_leveled <- mean(pb_dist)/max(pb_dist)
    print(paste("Ideal Leveled is",ideal_leveled));
    print(paste("PB Leveled is",pb_leveled));
    
    print(paste("Ideal improvement is",ideal_leveled/ideal_base));
    print(paste("PB improvement is",pb_leveled/pb_base));
}
