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

 

