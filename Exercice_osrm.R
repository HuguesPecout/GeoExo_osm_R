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

# Solution 1 - par attribut
loc_sen <- loc[loc$PAYS == "SN", ]
# Solution 2 - par localisation
loc_sen <- st_filter(x = loc, 
                     y = sen,
                     .predicate = st_intersects)



## B.2 Calculez le nombre de services présent dans chaque localité. 
#Assignez le résultat dans une nouvelle colonne de la couche géographique des localités sénégalaises.
loc_sen$SERV_TT <- rowSums(loc_sen[,5:17,drop=TRUE])


## B.3 Découpez le réseau routier en fonction des limites du Sénégal.
routes_sen <- st_intersection(x = routes, y = sen)



###################################################################################################
# C. Carte thématique des localités
###################################################################################################

# Paramètrage de l'export
mf_export(x = sen, filename = "img/carte_1.png", width = 800)
# Initialisation d'un thème
mf_theme(bg = "steelblue3", fg= "grey10")
# Centrage de la carte sur le Sénégal
mf_map(x = reg, col = NA, border = NA)
# Ajout des limites des pays voisins
mf_map(pays, add = TRUE)
# Ajout d'un effet d'ombrage sur le Sénégal
mf_shadow(sen, add = TRUE)
mf_map(sen, col = "grey95", add=T)
# Affichage du réseau routier
mf_map(routes_sen, col = "grey50", lwd = 0.4, add = TRUE)

# Affichage des localités 
# Symbols proportionnels = Nombre total de services / couleur = type de localité
mf_map(x = loc_sen, 
       var = c("SERV_TT", "TYPELOCAL"),
       type = "prop_typo",
       pal = "Reds", 
       rev = TRUE,
       inches = 0.06,
       leg_pos = NA)

# Ajout d'une annotation (localisation de USSEIN)
mf_annotation(x = USSEIN, txt = "USSEIN", halo = TRUE, bg = "grey85", cex = 1.1)

# Ajout de toponymes
text(x = 261744.7, y = 1766915, labels = "Océan\nAtlantique", col="#FFFFFF99", cex = 0.65)
text(x = 456008.1, y = 1490739, labels = "Gambie", col="#00000099", cex = 0.6)
text(x = 496293.2, y = 1364960, labels = "Guinée-Bissau", col="#00000099", cex = 0.6)
text(x = 748298.6, y = 1355112, labels = "Guinée", col="#00000099", cex = 0.6)
text(x = 875867.9, y = 1541766, labels = "Mali", col="#00000099", cex = 0.6)
text(x = 683394.9, y = 1818838, labels = "Mauritanie", col="#00000099", cex = 0.6)

# Reconstruction de la légende
# Legend sur le type de localités
mf_legend(type = "typo", 
          val = c("Chef-lieu de région", 	
                  "Chef-lieu de département",
                  "Chef-lieu d’arrondissement",
                  "Chef-lieu de communauté rurale ",
                  "Commune",
                  "Village important",
                  "Village",
                  "Commune d’arrondissement",
                  "Habitat isolé"), 
          pal = mf_get_pal(n = 9, palette = c("Reds")),
          title_cex = 0.7,
          val_cex = 0.5,
          size = 0.6,
          frame = TRUE,
          bg = "#FFFFFF99",
          title = "Statut des localités")

# Légende sur le nombre de services
mf_legend(type = "prop", 
          val = c(1,3,5,7,10), 
          inches = 0.06,
          title_cex = 0.7,
          title = "Nombre de\nservices",
          horiz = TRUE,
          frame = TRUE,
          bg = "#FFFFFF99",
          pos = "right")

# Titre
mf_title("Répartition des localités sénégalaises en 2024", fg = "white")
# Sources
mf_credits("Auteurs : Hugues Pecout\nSources : GADM & GeoSénégal, 2014", cex = 0.5)

# Enregistrement du fichier png
dev.off()




###################################################################################################
# D. Nombre d'écoles dans un rayon de 50km ?
###################################################################################################

## D.1. Calculez un buffer de 50 km autour d'USSEIN
# Vérification de l'unité de la projection
st_crs(USSEIN)

# Calcul d'un buffer de 5 kilomètres
buf_5km <- st_buffer(USSEIN, 50000)


## D.2. Séléctionnez les localités situées dans la zone tampon de 50km
# Intersection entre les localités et le buffer
inters_loc_buff <- st_intersection(loc, buf_5km)


## D.3 Combien de ces localités abrite au moins une école ?
# Nombre de localité dans un rayon de 50km ?
nb_loc_ecole_50km_USSEIN <- sum(inters_loc_buff$SERV_ECOLE)

# Affichage du résultat dans la console
cat(paste0("Le nombre de localités abritant (au moins) une école dans un rayon de 50 km autour de l'",
           USSEIN$NAME, " est de ", nb_loc_ecole_50km_USSEIN))


###################################################################################################
# E. Utilisation d’un maillage régulier
###################################################################################################

## E.1 Créez un maillage régulier de carreaux de 50km de côté sur l'ensemble du Sénégal
grid <- st_make_grid(sen, cellsize = 15000, square = TRUE)
# Transformer la grille en objet sf avec st_sf()
grid <- st_sf(geometry = grid)
# Ajouter un identifiant unique, voir chapitre 3.7.6
grid$id_grid <- 1:nrow(grid)


## E.2 Récuperez le carreau d'appartenance (id) de chaque localité.
grid_loc<- st_intersects(grid, loc, sparse = TRUE)


## E.3 Comptez le nombre de localités dans chacun des carreaux.
grid$n_loc <- sapply(grid_loc, FUN = length)


# E.4 Découpez la grille en fonction des limites du sénégal (optionel)
grid_sen <- st_intersection(grid, sen)




###################################################################################################
# F. Enregistrez la grille régulière dans le fichier GeoSenegal.gpkg
###################################################################################################

st_write(obj = grid_sen, dsn = "data/GeoSenegal.gpkg", layer = "grid_sen")




###################################################################################################
# G. Construisez une carte représentant le nombre de localité par carreau.
###################################################################################################


# Justification de la discrétisation (statistiques, boxplot, histogramme, beeswarm...) ?
hist(grid_sen$n_loc)

## CARTE
# Paramètrage de l'export
mf_export(x = sen, filename = "img/carte_2.png", width = 800)
# Initialisation d'un thème
mf_theme(bg = "steelblue3", fg= "grey10")
# Centrage de la carte sur le Sénégal
mf_map(x = reg, col = NA, border = NA)
# Ajout des limites des pays voisin
mf_map(pays, add = TRUE)
# Ajout d'un effet d'ombrage sur le Sénégal
mf_shadow(sen, add = TRUE)
mf_map(sen, col = "grey95", add=T)

# carte choroplèthe - Nombre de localité par carreaux
mf_map(x = grid_sen, 
       var = "n_loc", 
       type = "choro",
       add = T, 
       border = NA,
       leg_pos = "topright",
       leg_title = "Nombre de\nlocalités",
       leg_val_rnd = 0,
       breaks = c(0,0.1,1,2,3,4,5, max(grid_sen$n_loc)), 
       pal = "SunsetDark")

# Affichae du réseau routier
mf_map(routes_sen, lwd = .3, col ="#b5b3b5", add=T )
# Affichage des localités
mf_map(loc_sen, add=T, col = "white", pch = ".", cex = .1)
# Affichage des limite de région
mf_map(reg, col = NA, border = "white", add = T)

# Ajout d'une annotation (localisation de USSEIN)
mf_annotation(x = USSEIN, txt = "USSEIN", halo = TRUE, bg = "grey85", cex = 1.1)

# Ajout de toponymes
text(x = 261744.7, y = 1766915, labels = "Océan\nAtlantique", col="#FFFFFF99", cex = 0.65)
text(x = 456008.1, y = 1490739, labels = "Gambie", col="#00000099", cex = 0.6)
text(x = 496293.2, y = 1364960, labels = "Guinée-Bissau", col="#00000099", cex = 0.6)
text(x = 748298.6, y = 1355112, labels = "Guinée", col="#00000099", cex = 0.6)
text(x = 875867.9, y = 1541766, labels = "Mali", col="#00000099", cex = 0.6)
text(x = 683394.9, y = 1818838, labels = "Mauritanie", col="#00000099", cex = 0.6)

# Titre
mf_title("Nombre de localités sénégalaises dans un carroaye de 15km", fg = "white")
# Sources
mf_credits("Auteurs : Hugues Pecout\nSources : GADM & GeoSénégal, 2014", cex = 0.5)

# Enregistrement du fichier png
dev.off()





#---------------------------------------------------------------------------------------

# BONUS

library(potential)

# create_grid() is used to create a regular grid with the extent of an existing layer (x) and a specific resolution (res).
y <- create_grid(x = sen, res = 10000)

# create_matrix() is used to compute distances between objects.
d <- create_matrix(x = loc_sen, y = y)


# The potential() function computes potentials.
y$pot <- potential(x = loc_sen, y = y, d = d,
                   var = "SERV_POSTE", fun = "e",
                   span = 20000, beta = 2)

# It’s possible to express the potential relatively to its maximum in order to display more understandable values (Rich 1980).
y$pot2 <- 100 * y$pot / max(y$pot)




# It’s also possible to compute areas of equipotential with equipotential().
bks <- mf_get_breaks(y$pot, breaks = "q6")
iso <- equipotential(x = y, var = "pot", breaks = bks, mask = sen)




mf_theme(bg = "steelblue3", fg= "grey10")

mf_map(x = reg, col = NA, border = NA)
mf_map(pays, add = TRUE)

mf_shadow(reg, add = TRUE)
mf_map(reg, col = "grey95", add=T)


mf_map(x = iso, var = "min", type = "choro", 
       breaks = bks, 
       pal = hcl.colors(10, 'Teal'),
       lwd = .2,
       border = "#121725", 
       leg_pos = "topright",
       leg_val_rnd = 0,
       leg_title = "Potential of\nservices", add = TRUE)

mf_map(routes_sen, lwd = .3, col ="#b5b3b5", add=T )
mf_map(loc_sen, add=T, col = "white", pch = ".", cex = .1)
mf_map(reg, col = NA, border = "white", add = T)


mf_annotation(x = USSEIN, 
              txt = "USSEIN", 
              halo = TRUE, 
              bg = "grey85",
              cex = 1.1)

text(x = 261744.7, 
     y = 1766915, 
     labels = "Océan\nAtlantique", 
     col="#FFFFFF99", cex = 0.65)

text(x = 456008.1, 
     y = 1490739, 
     labels = "Gambie", 
     col="#00000099", cex = 0.6)

text(x = 496293.2, 
     y = 1364960, 
     labels = "Guinée-Bissau", 
     col="#00000099", cex = 0.6)

text(x = 748298.6, 
     y = 1355112, 
     labels = "Guinée", 
     col="#00000099", cex = 0.6)

text(x = 875867.9, 
     y = 1541766, 
     labels = "Mali", 
     col="#00000099", cex = 0.6)

text(x = 683394.9, 
     y = 1818838, 
     labels = "Mauritanie", 
     col="#00000099", cex = 0.6)

mf_title("Potentiel d'accès à des services", fg = "white")
mf_credits("Auteurs : Hugues Pecout\nSources : GADM & GeoSénégal, 2014", cex = 0.5)

