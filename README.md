# Geomatique & OSM avec R - Exercice appliqué <img src="img/logo.png" align="right" width="140"/>

### Master Géomatique - Université du Sine Saloum El-Hâdj Ibrahima NIASS

*Hugues Pecout*

</br>

#### **A. Téléchargement de l’espace de travail**

Un projet Rstudio est téléchargeable à ce lien : [**https://github.com/HuguesPecout/GeoExo_osm_R**](https://github.com/HuguesPecout/GeoExo_osm_R)

Téléchargez le dépot zipper ("*Download ZIP*") **GeoExo_osm_R** sur votre machine.   

</br>

![](img/download.png)

Une fois le dossier dézipper, lancez le projet Rstudio en double-cliquant sur le fichier **GeoExo_sosm_R.Rproj**.

</br>

#### **B. Les données à disposition**


Les fichier de données sont mis à disposition dans le répertoire **data**, qui contient un seul fichier de données.

![](img/data.png)


**Le fichier GeoPackage** (**GeoSenegal.gpkg**) contient 7 couches géographiques :

- **Pays_voisins** : Couche des frontières du Sénégal et de l'ensemble de ses pays limitrophes. Source : https://gadm.org/, 2014   
- **Senegal** : Couche des frontières du Sénégal. Source : https://gadm.org/, 2014   
- **Regions** : Couche des régions sénégalaises. Source : https://gadm.org/, 2014   
- **Departements** : Couche des Departements sénégalais. Source : https://gadm.org/, 2014   
- **Localites** : Couche de points des localités sénagalaises. Source : Base de données géospatiales prioritaires du Sénégal. https://www.geosenegal.gouv.sn/, 2014. 
- **USSEIN** : Localisation de l'Université du Sine Saloum El-hâdj ibrahima NIASS. Source : Google Maps, 2014. 
- **Routes** : Couche du réseau routier sénégalais. Source : Base de données géospatiales prioritaires du Sénégal. https://www.geosenegal.gouv.sn/, 2014. 

</br>


## **EXERCICE**

#### **En vous appuyant sur les manuels [Geomatique avec R](https://rcarto.github.io/geomatique_avec_r/) et [Cartographie avec R](https://rcarto.github.io/cartographie_avec_r/), effectuez les opérations suivantes dans le fichier Exercice_sf.R :**

</br>

#### A. Import des données

Importez l'ensemble des couches géographiques contenues dans le fichier GeoPackage **GeoSenegal.gpkg**.

    st_layers("data/GeoSenegal.gpkg")

    ... <- st_read(dsn = "data/GeoSenegal.gpkg", layer = "...")

</br>

#### B. Séléction et intersection spatiale


##### B.1 Séléctionnez (par attribut ou par localisation) uniquement les localités du Sénégal.

    # Solution 1 - par attribut
    ... <- ...[...$PAYS == "...", ]
    
    # Solution 2 - par localisation
    ... <- st_filter(x = ..., y = ..., .predicate = st_intersects)
    
</br>

##### B.2 Calculez le nombre de services présent dans chaque localité. Assignez le résultat dans une nouvelle colonne de la couche géographique des localités sénégalaises.

    ...$... <- rowSums(...[, 5:17, drop=TRUE])
    

</br>

##### B.3 Découpez le réseau routier en fonction des limites du Sénégal.

    ... <- st_intersection(x = ..., y = ...)


</br>


#### C. Carte thématique des localités

Construisez une carte thématique représentant les localités sénagalaise par leur nombre de services qu'elles abritent (symboles proportionnels) et par leur statut ("TYPELOCAL") représenter en couleur dans les symbols proportionnels. 

Exemple :

![](img/carte_1.png)

</br>
    
Pour vous aider, voici les étiquettes des différentes modialités préciser dans les métadonnées :  

- 1 = Chef-lieu de région    
- 2 = Chef-lieu de département   
- 3 = Chef-lieu d’arrondissement   
- 4 = Chef-lieu de communauté rurale   
- 5 = Commune   
- 6 = Village important   
- 7 = Village  
- 8 = Commune d’arrondissement   
- 9 = Habitat isolé   

</br>

      val = c("Chef-lieu de région", 
              "Chef-lieu de département", 
              "Chef-lieu d’arrondissement",
              "Chef-lieu de communauté rurale", 
              "Commune", 
              "Village important", 
              "Village",
              "Commune d’arrondissement", 
              "Habitat isolé")



</br>


#### D. Nombre d'écoles dans un rayon de 50km ?

Calculez le nombre de localité qui abrite au moins une école ("SERV_ECOLE") dans la couche géographique des localités) dans un rayon de 50km (distance euclidienne) autour de l'Université du Sine Saloum El-hâdj ibrahima NIASS (USSEIN)

</br>

##### D.1. Calculez un buffer de 50 km autour d'USSEIN

    ... <- st_buffer(USSEIN, ...)
    
</br>

##### D.2. Séléctionnez les localités situées dans la zone tampon de 50km

    inters_loc_buff <- st_intersection(..., ...)

</br>   
    
##### D.3 Combien de ces localités abrite au moins une école ?    
    
    ... <- sum(inters_loc_buff$...)
    

</br>


#### E. Utilisation d’un maillage régulier

##### E.1 Créez un maillage régulier de carreaux de 50km de côté sur l'ensemble du Sénégal

    grid <- st_make_grid(..., cellsize = ..., square = ...).
    
    # Transformer la grille en objet sf avec st_sf()
    grid <- st_sf(geometry = grid)
    
    # Ajouter un identifiant unique à chaque carreaux
    grid$id<- 1:nrow(grid)

</br>

##### E.2 Récuperez le carreau d'appartenance (id) de chaque localité.

    grid_loc <- st_intersects(..., ..., sparse = TRUE)
    
</br>

##### E.3 Comptez le nombre de localités dans chacun des carreaux.

    grid$... <- sapply(grid_loc, FUN = ...)
    
</br>   

##### E.4 Découpez la grille en fonction des limites du sénégal (optionel)

    grid_sen <- st_intersection(..., ...)
    

</br>

#### F. Enregistrez la grille régulière découpée par les limites de Sénégal dans le fichier **GeoSenegal.gpkg**

    st_write(obj = ..., dsn = "data/GeoSenegal.gpkg", layer = "...")

</br>

#### G. Construisez une carte représentant le nombre de localité par carreau.

Exemple : 

![](img/carte_2.png)

Quelles critiques pouvez-vous faire de cette carte thématique ? Les règles de sémiologie graphique sont-elles respectées ?


