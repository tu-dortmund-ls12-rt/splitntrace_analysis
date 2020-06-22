require(data.table)

import_nvmain_trace <- function(filename, min_address, max_address){
    #table <- read.table(filename, skip=1)
    table <- fread(filename, skip=1)
    #Walk through table
    rw <- table$V2
    address <- strtoi(table$V3)
    
    write_addresses <- address[rw == "W"]
    write_addresses <- write_addresses[write_addresses >= min_address]
    write_addresses <- write_addresses[write_addresses <= max_address]
    return(write_addresses)
}

import_nvmain_trace_rw <- function(filename, min_address, max_address){
    #table <- read.table(filename, skip=1)
    table <- fread(filename, skip=1)
    #Walk through table
    rw <- table$V2
    address <- strtoi(table$V3)
    
    write_addresses <- address[rw == "W" || rw == "R"]
    write_addresses <- write_addresses[write_addresses >= min_address]
    write_addresses <- write_addresses[write_addresses <= max_address]
    return(write_addresses)
}

import_nvmain_trace_r <- function(filename, min_address, max_address){
    #table <- read.table(filename, skip=1)
    table <- fread(filename, skip=1)
    #Walk through table
    rw <- table$V2
    address <- strtoi(table$V3)
    
    write_addresses <- address[rw == "R"]
    write_addresses <- write_addresses[write_addresses >= min_address]
    write_addresses <- write_addresses[write_addresses <= max_address]
    return(write_addresses)
}
