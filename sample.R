sample_data <- function(src_data, sample_rate){
    target_size <- (length(src_data)/sample_rate)
    target <- rep(0,target_size)
    
    for(i in 1:target_size){
        target[i]=max(src_data[seq(1,sample_rate)+((i-1)*sample_rate)])
    }
    return(target)
}
