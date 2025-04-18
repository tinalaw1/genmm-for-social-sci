#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
# Collect Static and Street View Images for Sites
# Project: Generative Multimodal Models for Social Science: 
#   An Application with Satellite and Street Imagery
# Author: Elizabeth Roberto, Rice University (eroberto@rice.edu)
# Created: June 20, 2024
# Updated: April 8, 2025
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #


  # Working Directory
    # setwd("")

  # Install Libraries (if needed)
    if(!require("sf")) install.packages("sf")
    if(!require("foreach")) install.packages("foreach")
    if(!require("RgoogleMaps")) install.packages("RgoogleMaps")

  # Load Libraries
    library(sf)
    library(foreach)
    library(RgoogleMaps)


  # Assign your Google API key here
    API_key <- ""


  # Import the csv file with test sites
    sites <- read.csv("TestSites.csv")


#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
# Define Functions
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #


  # See: https://developers.google.com/maps/documentation/maps-static/start
  #  for information about Google Maps parameter values

  # Arguments used in functions below:
    # id        Unique identifier for the site
    # site      A named list or data.frame row with data about the site
    # size      Numeric vector of length 2: c(width, height)
    # maparea   A data.frame with columns X and Y defining the bounding box
    # scale     Google Maps scale paremeter (1 or 2)
    # maptype   Google Maps type ("satellite", "roadmap", "terrain", "hybrid")
    # format    Image format (e.g., "png32", "jpg")
    # API_key   Your Google API key
    # verbose   TRUE if you would like to print the image url, FASLE otherwise


  # Function to collect static map images
    SaveMapImage <- function(id, site, size=c(640, 640), 
      maparea, scale=2, maptype="satellite", format="png32", 
      API_console_key="", verbose=TRUE) {

      # Find the desired zoom level for the map image
        zoom <- RgoogleMaps::MaxZoom(
          latrange=maparea[, "Y"], lonrange=maparea[, "X"], 
          size=size)

      # Construct the url for the map image
        googleurl <- "https://maps.googleapis.com/maps/api/staticmap?"
        path <- paste0("&path=color:0xff0000|weight:5|",
          site[, "latitudeF"], ",", site[, "longitudeF"], "|",
          site[, "latitudeT"], ",", site[, "longitudeT"])
        urlStr <- paste0(googleurl, "&zoom=", zoom,
          "&size=", paste(size, collapse="x"), "&scale=", scale,
          "&maptype=", maptype, "&format=", format, 
          "&key=", API_console_key, path)

      # Print the url for the map image if verbose=TRUE
        if(verbose) print(urlStr)

      # Save the map image
        destfile <- paste0(id, "_", zoom, ".png")
        download.file(urlStr, destfile, mode="wb", quiet=TRUE)

      # Return value
        # value can be assigned; will not print otherwise (if verbose=FALSE)
        invisible(urlStr)

    } # close function



  # Function to collect street view images
    SaveStreetView <- function(id, site, size=c(640, 640),
      API_console_key="", verbose=TRUE) {

      # Base of the url for the street view images
        googleurl <- "https://maps.googleapis.com/maps/api/streetview?"


      # First street view

        # Construct the url
          urlStr1 <- paste0(googleurl, "size=", paste(size, collapse="x"),
            "&location=", paste0(site[, "latitudeF"], ",", site[, "longitudeF"]),
            "&heading=", site[, "bearingFT"], "&pitch=0", "&fov=120",
            "&key=", API_console_key)

        # Print the url if verbose=TRUE
          if(verbose) print(urlStr1)

        # Save the map image
          destfile <- paste0(id, "_FT", ".png")
          download.file(urlStr1, destfile, mode="wb", quiet=TRUE)


      # Second street view

        # Construct the url
          urlStr2 <- paste0(googleurl, "size=", paste(size, collapse="x"),
            "&location=", paste0(site[, "latitudeT"], ",", site[, "longitudeT"]),
            "&heading=", site[, "bearingTF"], "&pitch=0", "&fov=120",
            "&key=", API_console_key)

        # Print the url if verbose=TRUE
          if(verbose) print(urlStr2)

        # Save the map image
          destfile <- paste0(id, "_TF", ".png")
          download.file(urlStr2, destfile, mode="wb", quiet=TRUE)


      # Return value
        # value can be assigned; will not print otherwise (if verbose=FALSE)
        invisible(c(urlStr1, urlStr2))

    } # close function



  # Bearing functions

    # Websites used to find the bearing formulas: 
    # https://www.igismap.com/
    #  formula-to-find-bearing-or-heading-angle-between-two-points-latitude-longitude/
    # https://www.movable-type.co.uk/scripts/latlong.html


    deg2rad <- function(deg) {
      return(deg * pi / 180)
    } # close function


    rad2deg <- function(rad) {
      return(rad * 180 / pi)
    } # close function


    bearing <- function(lat1, lon1, lat2, lon2) {

      # Convert latitude and longitude from degrees to radians
        lat1 <- deg2rad(lat1)
        lon1 <- deg2rad(lon1)
        lat2 <- deg2rad(lat2)
        lon2 <- deg2rad(lon2)
        
      # Calculate the difference in longitude
        dLon <- lon2 - lon1
      
      # Calculate the bearing
        y <- sin(dLon) * cos(lat2)
        x <- cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        bearing <- atan2(y, x)
      
      # Convert bearing from radians to degrees
        bearing <- rad2deg(bearing)
      
      # Normalize bearing to be within 0 to 360 degrees
        bearing <- (bearing + 360) %% 360

      # Return value
        return(bearing)

    } # close function


#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
# Calculate the Headings (Bearings)
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #


  # Calculate the Headings (Bearings) for Google Street View Image Requests

    # Add new columns to store the bearings
      sites$bearingFT <- NA  # Bearing from F to T
      sites$bearingTF <- NA  # Bearing from T to F

    # Loop through each row of the dataset to calculate the bearings
      for(i in 1:nrow(sites)) {

        # Latitude and longitude for the endpoints of the site
          lonF <- sites$longitudeF[i]
          latF <- sites$latitudeF[i]
          lonT <- sites$longitudeT[i]
          latT <- sites$latitudeT[i]

        # Calculate the bearing from F to T
          sites$bearingFT[i] <- bearing(latF, lonF, latT, lonT)

        # Calculate the bearing from T to F
          sites$bearingTF[i] <- bearing(latT, lonT, latF, lonF)

      } # close for loop



#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
# Create mapareas
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #


  # Note: the foreach loop can be parallelized using a
  #  registered parallel backend and replaceing %do% with %dopar%

  # Create mapareas -- a buffered area around each site
    mapareas <- foreach(i=1:nrow(sites)) %do% {

      # Create a spatial object representing the line 
      #  between the two endpoints of the site
        out1a <- sf::st_linestring(x=matrix(unlist(
          sites[i, c("longitudeF", "latitudeF", "longitudeT", "latitudeT")]),
          ncol=2, byrow=TRUE))
        out1b <- sf::st_sfc(out1a, crs="EPSG:4326")

      # Buffer the line by 25 meters to be sure the
      #  satellite image will include the endpoints of the line
        out1c <- sf::st_buffer(out1b, dist=25)

      # Return the range of the coordinates for this area
        apply(sf::st_coordinates(out1c)[, 1:2], 2, range)

    } # close foreach


#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #
# Collect Images
#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #


  # Collect Static Satellite Images -- loop over the sites
    for(i in 1:nrow(sites)) {
      SaveMapImage(site=sites[i, ], maparea=mapareas[[i]], id=sites[i, "id"],
        API_console_key=API_key, verbose=TRUE)
    } # close for loop


  # Collect Street View Images -- loop over the sites
    for(i in 1:nrow(sites)) {
      SaveStreetView(site=sites[i, ], id=sites[i, "id"],
        API_console_key=API_key, verbose=TRUE)
    } # close for loop


#  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #  #












