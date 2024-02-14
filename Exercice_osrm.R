###################################################################################################
#                                                                                                 #
#                             Geomatique avec R - Exercice appliqué                               #
#                                                                                                 #
###################################################################################################


###################################################################################################
# Chargement des librairies
###################################################################################################

library(sf)
library(mapsf)


###################################################################################################
# A. Import des données
###################################################################################################

# Lister les couches géographiques d'un fichier GeoPackage
st_layers("data/GeoSenegal.gpkg")

# Import des données géographiques
pays <- st_read(dsn = "data/GeoSenegal.gpkg", layer = "Pays_voisins")
sen <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Senegal")
reg <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Regions")
dep <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Departements")
loc <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Localites")
USSEIN <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "USSEIN")
routes <-st_read(dsn = "data/GeoSenegal.gpkg", layer = "Routes")




###################################################################################################
# B. Séléction et intersection spatiale
###################################################################################################

## B.1 Séléctionnez (par attribut ou par localisation) uniquement les localités du Sénégal.


##---------------------- Géocodage adresse ---------------------------##

# Construction d'un data.frame avec nom et adresse
Mosquee_Touba <- data.frame(name = "Grande Mosquée de Touba",
                            addresse = "Grande Mosquée de Touba, Sénégal")



# Géocodage de l'adresse à partir de la base de données OpenStreetMap
library(tidygeocoder)
Mosquee_Touba_loc <- geocode(.tbl = Mosquee_Touba, address =  addresse)





##----------------- Création d'un point (objet sf) ------------------##

library(sf)

# Création objet sf
Mosquee_Touba_sf <- st_as_sf(Mosquee_Touba_loc, coords = c("long", "lat"), crs = 4326)

# Transformation de la projection en Pseudo-Mercator (3857)
Mosquee_Touba_sf <- st_transform(Mosquee_Touba_sf, crs = "EPSG:32628")





##----------- Visualisation du point - carte interactive ------------##

library(mapview)
mapview(Mosquee_Touba_sf)






dep_pt <- st_centroid(dep)





##-------------- Extraction de tuile OpenStreetMap -----------------##

library(maptiles)
osm_tiles <- get_tiles(x = st_buffer(sen, dist = 30000), zoom = 8, crop = TRUE)




##-------------------- Affichage des données -----------------------##
library(mapsf)
mf_raster(osm_tiles)
mf_map(dep_pt, border = NA, col="blue" , cex = 2, pch = 20, add = TRUE)
mf_map(dep, border = "black", col=NA , add = TRUE)
mf_map(Mosquee_Touba_sf, border = NA, col="red" , cex = 3, pch = 20, add = TRUE)
mtext(side = 1, line = -1, text = get_credit("OpenStreetMap"), col="tomato")

mf_export(x = sen, filename = "img/carte_osm.png", width = 800)
library(mapsf)
plot_tiles(osm_tiles)
mf_map(dep_pt, border = NA, col="blue" , cex = 2, pch = 20, add = TRUE)
mf_map(dep, border = "black", col=NA , add = TRUE)
mf_map(Mosquee_Touba_sf, border = NA, col="red" , cex = 3, pch = 20, add = TRUE)
mtext(side = 1, line = -1, text = get_credit("OpenStreetMap"), col="tomato")
dev.off()



#####------------ Calcul de matrice de distance -----------------#####

#------------------- Distance Euclidienne ---------------------------#

mat_eucli_km <- st_distance(x = Mosquee_Touba_sf, y = dep_pt) 

# Changement nom de ligne et de colonne
rownames(mat_eucli_km) <- Mosquee_Touba_sf$name
colnames(mat_eucli_km) <- dep_pt$NAME_2



#---------------- Distance et temps par la route  -------------------#

library(osrm)
dist <- osrmTable(src = Mosquee_Touba_sf, 
                  dst = dep_pt,
                  measure = c("distance", "duration"))



#------ Ajout des valeurs (+ conversion) comme attributs des agglomérations ---------#

# mètres -> kilomètres
dep_pt$IRSP_eucli_dist <- as.numeric(mat_eucli_km) / 1000

# mètres -> kilomètres
dep_pt$IRSP_route_km <- as.numeric(dist$distances) / 1000

# Minutes -> heures
dep_pt$IRSP_route_hr <- as.numeric(dist$durations) / 60




#####---------------------- Calcul d'indice ----------------------#####

#------------------ Calcul indice d'accessibilité  -------------------#

mean(dep_pt$IRSP_eucli_dist)
max(dep_pt$IRSP_eucli_dist)

mean(dep_pt$IRSP_route_km)
max(dep_pt$IRSP_route_km)

mean(dep_pt$IRSP_route_hr)
max(dep_pt$IRSP_route_hr)



#------------------ Calcul indice de performance ---------------------#

# Indice de sinuosité 
dep_pt$ind_sinuo <- round(dep_pt$IRSP_route_km / dep_pt$IRSP_eucli_dist, 2)

# Indice de vitesse sur route
dep_pt$ind_speed <- round(dep_pt$IRSP_route_km / dep_pt$IRSP_route_hr, 1)

# Indice global de performance
dep_pt$ind_perf <- round(dep_pt$ind_speed / dep_pt$ind_sinuo, 1)



#---------- Cartographie de l'indice global de performance----------#

library(mapsf)

# mf_export(x = st_buffer(sen, dist = 30000), filename = "img/carte_indice_perf.png", width = 800)

plot_tiles(osm_tiles)
mf_map(x = dep_pt,
       var = "ind_perf",
       type = "choro",
       pal = "Dark Mint",
       leg_pos = "topright2",
       leg_title = "Indice de\nperformance\nglobale",
       breaks = "jenks",
       nbreaks = 8,
       leg_val_rnd = 0,
       border=NA,
       cex = 2,
       add = TRUE)

mf_map(Mosquee_Touba_sf, border = "red", col="red" , lwd = 10, pch = 20, add = TRUE)
mtext(side = 1, line = -1, text = get_credit("OpenStreetMap"), col="tomato")

# dev.off()




#--- Agglomération avec le plus haut indice global de performance ----#


# Sélection de l'agglomération présentant l'indice global le plus élevé
city_max_perf <- dep_pt[dep_pt$ind_perf == max(dep_pt$ind_perf),]




#---------- Calcul d'itinéraire entre IRSP et city_max_perf ----------#

route <- osrmRoute(src = Mosquee_Touba_sf, dst = city_max_perf)

# Affichage de l'itinéraire
plot_tiles(osm_tiles)
plot(st_geometry(route), col = "grey10", lwd = 6, add = TRUE)
plot(st_geometry(route), col = "grey90", lwd = 1, add = TRUE)
plot(st_geometry(Mosquee_Touba_sf), border = NA, col="red", pch = 20, cex = 3, add = TRUE)
plot(st_geometry(city_max_perf), border = NA, col="red", pch = 20, cex = 3, add = TRUE)
mtext(side = 1, line = -1, text = get_credit("OpenStreetMap"), col="tomato")
