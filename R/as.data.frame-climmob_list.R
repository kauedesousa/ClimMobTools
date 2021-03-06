#' @rdname getDataCM
#' @param x an object of class \code{CM_list}
#' @param tidynames logical, if \code{TRUE} suppress ODK strings
#' @param pivot.wider logical, if \code{TRUE} return a wider object 
#'  where each observer is a row
#' @param ... additional arguments passed to methods
#' @importFrom methods as
#' @method as.data.frame CM_list
#' @export
as.data.frame.CM_list <- function(x, 
                                  ...,
                                  tidynames = TRUE,
                                  pivot.wider = FALSE) {
  
  dt <- list()
  # 'specialfields', the assessment questions
  dt[["specialfields"]] <- x[["specialfields"]]
  
  # 'project', the project details
  dt[["project"]] <- x[["project"]]
  
  # 'registry', the questions during participant registration
  dt[["registry"]] <- x[["registry"]]
  
  # importantfields
  dt[["importantfields"]] <- x[["importantfields"]]
  
  # 'assessments', the survey in trial data assessment
  dt[["assessments"]] <- x[["assessments"]]
  
  # 'packages', the packages info
  dt[["packages"]] <- x[["packages"]]
  
  # 'data', the trial data assessment
  dt[["data"]] <- x[["data"]]
  
  # get the project name
  project_name <- dt[["project"]]$project_cod
  
  # get variables names from participant registration
  regs <- dt[["registry"]]
  
  regs <- regs[["fields"]]
  
  regs_name <- paste0("REG_", regs[, "name"])
  
  has_data <- length(dt[["data"]]) > 0
  
  ncomp <- dt$project$project_numcom
  
  if (isTRUE(has_data)) {
    
    # get the names of assessments questions
    assess_q <- dt[["specialfields"]]
    #assess_q <- assess_q[, "name"]
    
    # check if overall VS local is present
    tricotvslocal <- grepl("Performance", assess_q$type)
    
    # get the ranking questions
    rank_q <- assess_q$name[!tricotvslocal]
    
    # and the overall vs local question
    tricotvslocal <- assess_q$name[tricotvslocal]
    
    # get variables names from assessments
    assess <- dt[["assessments"]]
    
    
    if(length(assess) > 0) {
      
      assess <- do.call("rbind", assess[, "fields"])
      assess <- data.frame(assess, stringsAsFactors = FALSE)
      assess <- assess[!duplicated(assess[, "name"]), ]
      # the ids for assessments
      assess_id <- paste0("ASS", dt[["assessments"]][, "code"])
      # and the description
      assess_name <- dt[["assessments"]][, "desc"]
      # the names of questions
      looknames <- assess[, "name"]
      
      # get codes from multiple choice variables
      assess_lkp <- dt$assessments$lkptables
      lkp <- list()
      for(i in seq_along(assess_lkp)){
        l <- .decode_lkptable(assess_lkp[[i]])
        lkp <- c(lkp, l)
      }
      
      
    } else {
      assess <- data.frame()
      assess_id <- character()
      assess_name <- character()
      looknames <- character()
      lkp <- list()
    }
    
    # add codes from registration
    reg_lkp <- .decode_lkptable(dt$registry$lkptables)
    
    lkp <- c(reg_lkp, lkp)
    
    # remove lkp table with farmers names
    keep <- !grepl("qst163", names(lkp))
    
    lkp <- lkp[keep]
    
    # paste the ids of each assessments
    looknames <- c(regs_name,
                   paste(rep(assess_id, each = length(looknames)), 
                         looknames, sep = "_"))
    
    
    # trial data
    trial <- dt[["data"]]
    
    # get the values from the trial data
    trial <- lapply(looknames, function(x){
      i <- names(trial) %in% x
      y <- trial[i]
      y
    })
    
    trial <- do.call("cbind", trial)
    
    # now replace codes from lkp tables in the trial data
    names(lkp) <- gsub("_opts$","",names(lkp))
    
    keep <- names(lkp) %in% names(trial)
    
    lkp <- lkp[keep]
    
    # remove assessment questions
    keep <- !names(lkp) %in% assess_q$name
    
    lkp <- lkp[keep]
    
    nm_lkp <- names(lkp)
    
    for(i in seq_along(lkp)){
      l <- lkp[[i]]
      trial[[nm_lkp[i]]] <- factor(trial[[nm_lkp[i]]], levels = l$id, labels = l$label)
      
    }
    
    # split geolocation info
    # check if geographic location is available
    geoTRUE <- grepl("farmgoelocation|geopoint|gps", names(trial))
    
    # if is available, then split the vector as lon lat
    if(any(geoTRUE)){
      
      geo_which <- which(geoTRUE)
      
      geo <- trial[geo_which]
      
      trial <- trial[!geoTRUE]
      
      for (i in seq_along(geo_which)){
        newname <- names(geo)[[i]]
        newname <- gsub("farmgoelocation", "_farm_geo", newname)
        newname <- gsub("__", "_", newname)
        newname <- paste0(newname, c("_longitude","_latitude"))
        
        lonlat <- geo[i]
        
        lonlat[is.na(lonlat)] <- c("NA NA NA NA")
        lonlat[lonlat == ""] <- c("NA NA NA NA")
        
        lonlat <- t(apply(lonlat, 1, function(x) {
          
          unlist(strsplit(x, " "))
          
        }))
        
        lonlat[lonlat == "NA"] <- NA
        
        lonlat <- lonlat[, c(2,1)]
        
        lonlat <- as.data.frame(lonlat, stringsAsFactors = FALSE)
        
        names(lonlat) <- newname
        
        lonlat <- apply(lonlat, 2, as.numeric)
        
        trial <- cbind(trial, lonlat)
        
      }
    }
    
    # replace numbers in trial results by LETTERS
    if (ncomp == 3) {
      trial[rank_q] <-
        lapply(trial[rank_q], function(x) {
          y <- as.integer(x)
          LETTERS[y]
        })
    }
    
    # replace numbers in question about overall vs local 
    if (length(tricotvslocal) > 1) {
      trial[tricotvslocal] <-
        lapply(trial[tricotvslocal], function(x) {
          y <- factor(x, levels = c("1", "2"), labels = c("Better", "Worse"))
          as.character(y)
        })
    }
    
    # reshape it into a long format 
    # put pack id as first colunm
    packid <- grepl("REG_qst162", names(trial))
    
    trial <- cbind(trial[packid], trial[!packid])
    
    trial <- .set_long(trial, "REG_qst162")
    
    trial$moment <- "registration"
    
    # remove possible space in assess name
    assess_name <- gsub(" ", "", assess_name)
    
    # add which moment the data was taken
    for (i in seq_along(assess_id)) {
      trial$moment <- ifelse(grepl(assess_id[i], trial$variable),
                             tolower(assess_name[i]),
                             trial$moment)
      
    }
    
  } else {
    trial <- data.frame()
    assess_id <- 1
    assess_name <- character()
  }
  
  # comparisons and package
  comps <- dt[["packages"]][, "comps"]
  
  if (ncomp == 3) {
    comps <- lapply(comps, function(x) {
      x <- unique(unlist(x$technologies))
      x <- x[-1]
      names(x) <- paste0("item_", LETTERS[1:length(x)])
      x
    })
  }
  
  if (ncomp > 3) {
    comps <- lapply(comps, function(x) {
      x <- unique(unlist(x$technologies))
      x <- x[-1]
      names(x) <- paste0("item_", 1:length(x))
      x
    })
  }
  
  comps <- do.call("rbind", comps)
  
  comps <- as.data.frame(comps, stringsAsFactors = FALSE)
  
  pack <- cbind(dt[["packages"]][, c("package_id","farmername")], comps)
  
  # add project name
  pack$project_name <- project_name
  
  pack <- .set_long(pack, "package_id")
  
  pack[, "moment"] <- "package"
  
  trial <- rbind(pack, trial)
  
  # check if ids from ODK names are required to be removed 
  if (isTRUE(tidynames)) {
    
    trial[, "variable"] <- gsub("REG_", "", trial[, "variable"])
    
    for (i in seq_along(assess_id)) {
      trial[, "variable"] <- gsub(paste0(assess_id[i], "_"), "", 
                                  trial[, "variable"])
    }
    
    ovl <- which(grepl("perf_overallchar", trial[, "variable"]))
    
    trial[ovl, "variable"] <- sapply(trial[ovl, "variable"], function(x) {
      x <- strsplit(x, split = "_")
      x <- paste0("item_", LETTERS[as.integer(x[[1]][3])], "_vs_local")
      x
    })
    
    trial[, "variable"] <- gsub("char_", "", trial[, "variable"])
    
    trial[, "variable"] <- gsub("stmt_", "pos", trial[, "variable"])
    
    trial[, "variable"] <- gsub("clm_", "survey_", trial[, "variable"])
    
    trial[, "variable"] <- gsub("^_","", trial[, "variable"])
    
    i <- trial[, "variable"] == "farmername"
    
    trial[i, "variable"] <- "participant_name"
    
  }
  
  output <- trial[, c("id","moment","variable","value")]
  
  # remove some ODK variables
  output <- output[!grepl("originid|rowuuid|qst163", output[[3]]), ]
  
  # reorder rows and make sure that packages and registration comes first
  assess_name <- sort(tolower(assess_name))
  output$moment <- factor(output$moment, levels = c("package",
                                                    "registration",
                                                    assess_name))
  
  
  # reorder moment and ids
  o <- order(output$moment)
  output <- output[o, ]
  
  output$id <- as.integer(output$id)
  o <- order(output$id)
  output <- output[o, ]
  
  # if required, put the data in wide format
  if (isTRUE(pivot.wider)) {
    
    output$variable <- paste(output$moment, output$variable, sep = "_")
    
    variable_levels <- unique(output$variable)
    
    output <- output[, -2]
    
    output <- .set_wide(output, "id")
    
    output <- output[,c("id", variable_levels)]
    
  }
  
  row.names(output) <- seq_along(output$id)
  
  class(output) <- union("CM_df", class(output))
  
  return(output)
  
}
