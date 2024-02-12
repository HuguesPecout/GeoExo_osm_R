########################################################################
####-------------------- OpenStreetMap & R ------------------------ ####
########################################################################


##--------------------------- PACKAGES -------------------------------##

# install.packages("tidygeocoder")
# install.packages("sf")
# install.packages("mapview")
# install.packages("maptiles")
# install.packages("osrm")




##---------------------- Géocodage adresse ---------------------------##


# Construction d'un data.frame avec nom et adresse
USSEIN_Add <- data.frame(name = "USSEIN",
                             addresse = "Grande Mosquée de Touba, Sénégal")

# Géocodage de l'adresse à partir de la base de données OpenStreetMap
library(tidygeocoder)
USSEIN_loc <- geocode(.tbl = USSEIN_Add, address =  addresse)




##----------------- Création d'un point (objet sf) ------------------##

library(sf)

# Création objet sf
USSEIN_sf <- st_as_sf(USSEIN_loc, coords = c("long", "lat"), crs = 4326)

# Transformation de la projection en Pseudo-Mercator (3857)
USSEIN_sf <- st_transform(USSEIN_sf, crs = 3857)


##----------- Visualisation du point - carte interactive ------------##

library(mapview)
mapview(USSEIN_sf)





##----------------- Import des données Africapolis ------------------##

africapolis <- st_read("data//africapolis_extract.shp",  quiet = TRUE)

# Transformation de la projection en Pseudo-Mercator (3857)
africapolis <- st_transform(africapolis, crs = 3857)
# africapolis <- st_transform(africapolis, crs = st_crs(IRSP_sf))



##------------- Sélection de agglomérations Béninoises --------------##

africapolis_ben <- africapolis[africapolis$ISO3 == "BEN", ]




##----------- Extraction des centroides d'agglomérations ------------##

africapolis_ben_pt <- st_centroid(africapolis_ben)




##-------------- Extraction de tuile OpenStreetMap -----------------##

library(maptiles)
osm_tiles <- get_tiles(x = st_buffer(africapolis_ben_pt, 30000), zoom = 8, crop = TRUE)




##-------------------- Affichage des données -----------------------##
plot_tiles(osm_tiles)
plot(st_geometry(africapolis_ben_pt), border = NA, col="blue" , cex = 2, pch = 20, add = TRUE)
plot(st_geometry(IRSP_sf), border = NA, col="red" , cex = 3, pch = 20, add = TRUE)
mtext(side = 1, line = -1, text = get_credit("OpenStreetMap"), col="tomato")





#####------------ Calcul de matrice de distance -----------------#####


#------------------- Distance Euclidienne ---------------------------#

mat_eucli_km <- st_distance(x = IRSP_sf, y = africapolis_ben_pt) 

# Changement nom de ligne et de colonne
rownames(mat_eucli_km) <- IRSP_sf$name
colnames(mat_eucli_km) <- africapolis_ben_pt$agglosName


#---------------- Distance et temps par la route  -------------------#

library(osrm)
dist <- osrmTable(src = IRSP_sf, 
                  dst = africapolis_ben_pt,
                  measure = c("distance", "duration"))
                  


#------ Ajout des valeurs (+ conversion) comme attributs des agglomérations ---------#

# mètres -> kilomètres
africapolis_ben_pt$IRSP_eucli_dist <- as.numeric(mat_eucli_km) / 1000

# mètres -> kilomètres
africapolis_ben_pt$IRSP_route_km <- as.numeric(dist$distances) / 1000

# Minutes -> heures
africapolis_ben_pt$IRSP_route_hr <- as.numeric(dist$durations) / 60




#####---------------------- Calcul d'indice ----------------------#####


#------------------ Calcul indice d'accessibilité  -------------------#

mean(africapolis_ben_pt$IRSP_eucli_dist)
max(africapolis_ben_pt$IRSP_eucli_dist)

mean(africapolis_ben_pt$IRSP_route_km)
max(africapolis_ben_pt$IRSP_route_km)

mean(africapolis_ben_pt$IRSP_route_hr)
max(africapolis_ben_pt$IRSP_route_hr)



#------------------ Calcul indice de performance ---------------------#

# Indice de sinuosité 
africapolis_ben_pt$ind_sinuo <- round(africapolis_ben_pt$IRSP_route_km / africapolis_ben_pt$IRSP_eucli_dist, 2)

# Indice de vitesse sur route
africapolis_ben_pt$ind_speed <- round(africapolis_ben_pt$IRSP_route_km / africapolis_ben_pt$IRSP_route_hr, 1)

# Indice global de performance
africapolis_ben_pt$ind_perf <- round(africapolis_ben_pt$ind_speed / africapolis_ben_pt$ind_sinuo, 1)



#---------- Cartographie de l'indice global de performance----------#

library(mapsf)

plot_tiles(osm_tiles)
mf_map(x = africapolis_ben_pt,
       var = "ind_perf",
       type = "choro",
       pal = "Dark Mint",
       leg_pos = "bottomleft2",
       leg_title = "Indice de performance globale",
       breaks = "jenks",
       nbreaks = 8,
       leg_val_rnd = 0,
       border=NA,
       cex = 2,
       add = TRUE)

plot(st_geometry(IRSP_sf), border = "red", col="red" , lwd = 10, pch = 20, add = TRUE)
mtext(side = 1, line = -1, text = get_credit("OpenStreetMap"), col="tomato")




#--- Agglomération avec le plus haut indice global de performance ----#


# Sélection de l'agglomération présentant l'indice global le plus élevé
city_max_perf <- africapolis_ben_pt[africapolis_ben_pt$ind_perf == max(africapolis_ben_pt$ind_perf),]




#---------- Calcul d'itinéraire entre IRSP et city_max_perf ----------#

route <- osrmRoute(src = IRSP_sf, dst = city_max_perf)

# Affichage de l'itinéraire
plot_tiles(osm_tiles)
plot(st_geometry(route), col = "grey10", lwd = 6, add = TRUE)
plot(st_geometry(route), col = "grey90", lwd = 1, add = TRUE)
plot(st_geometry(IRSP_sf), border = NA, col="red", pch = 20, cex = 3, add = TRUE)
plot(st_geometry(city_max_perf), border = NA, col="red", pch = 20, cex = 3, add = TRUE)
mtext(side = 1, line = -1, text = get_credit("OpenStreetMap"), col="tomato")
