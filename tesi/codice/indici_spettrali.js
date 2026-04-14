// AREA DI STUDIO
var areaStudio = Buffer;


// CARICAMENTO COLLEZIONE SENTINEL-2
var S2 = ee.ImageCollection("COPERNICUS/S2_SR_HARMONIZED")
.filterBounds(areaStudio)
.filterDate("2020-06-01", "2020-08-31") 
.filter(ee.Filter.lt("CLOUDY_PIXEL_PERCENTAGE", 50))
.median()
.clip(areaStudio);

// NDVI


// Selezione bande
var NIR = S2.select("B8");
var RED = S2.select("B4");

// Calcolo indice
var NDVI = NIR.subtract(RED)
.divide(NIR.add(RED))
.rename("NDVI");

// Esportazione
Export.image.toDrive({
image: NDVI,
description: "NDVI_2020",
scale: 50,
maxPixels: 1e13,
region: areaStudio
});

// NDWI


var NDWI = S2.normalizedDifference(["B3", "B8"])
.rename("NDWI");

Export.image.toDrive({
image: NDWI,
description: "NDWI_2020",
scale: 50,
maxPixels: 1e13,
region: areaStudio
});

// SAVI


var L = 0.5;

var SAVI = S2.expression(
"((NIR - RED) * (1 + L)) / (NIR + RED + L)",
{
NIR: S2.select("B8"),
RED: S2.select("B4"),
L: L
}
).rename("SAVI");

Export.image.toDrive({
image: SAVI,
description: "SAVI_2020",
scale: 50,
maxPixels: 1e13,
region: areaStudio
});

// LAI (derivato da EVI)

// Normalizzazione bande
var image = S2.select(["B2", "B4", "B8"]);

var NIR_lai  = image.select("B8").divide(10000);
var RED_lai  = image.select("B4").divide(10000);
var BLUE_lai = image.select("B2").divide(10000);

// Calcolo EVI
var EVI = image.expression(
  "2.5 * ((NIR - RED) / (NIR + 6 * RED - 7.5 * BLUE + 1))",
  {
    NIR: NIR_lai,
    RED: RED_lai,
    BLUE: BLUE_lai
  }
).rename("EVI");

// Calcolo LAI
var LAI = EVI.expression(
  "max(0, 3.618 * EVI - 0.118)",
  { EVI: EVI }
).rename("LAI");

Export.image.toDrive({
  image: LAI,
  description: "LAI_2020",
  scale: 50,
  maxPixels: 1e13,
  region: areaStudio
