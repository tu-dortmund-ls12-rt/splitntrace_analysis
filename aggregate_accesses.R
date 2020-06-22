aggregate_accesses <- function(write_addresses, address_step, min_g, max_g){
    min_address=min_g
    max_address=max_g;
    print(paste("Min Addr: 0x", as.hexmode(min_address)))
    print(paste("Max Addr: 0x", as.hexmode(max_address)))
    print(paste(paste("Every write goes to",address_step),"bytes"))
    
    access_histogram_size <- max_address-min_address;
    access_histogram <- rep(0,access_histogram_size);
    
    for(write in write_addresses){
        write_region <- write-min_address
        write_region_start <- floor(write_region / address_step) * address_step
        hist_offset <- write_region_start+1 #R counts from 1
        #Increment the write count for every written byte
        for(byte in seq(0,address_step-1)){
            access_histogram[hist_offset + byte] <- access_histogram[hist_offset + byte]+1
        }
    }
    
    return(access_histogram)
}
