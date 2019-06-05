// // Creating maps objects
const internet_map = L.map("internet_map", {
    center: [35,0],
    zoom: 1.4,
    zoomControl: false,
    dragging: false,
    scrollWheelZoom: false,
    doubleClickZoom: false
})

const polity_map = L.map("polity_map", {
        center: [35,0],
        zoom: 1.4,
        zoomControl: false,
        dragging: false,
        scrollWheelZoom: false,
        doubleClickZoom: false
})

const corruption_map = L.map("corruption_map", {
        center: [35,0],
        zoom: 1.4,
        zoomControl: false,
        dragging: false,
        scrollWheelZoom: false,
        doubleClickZoom: false
})

const freedom_map = L.map("freedom_map", {
        center: [35,0],
        zoom: 1.4,
        zoomControl: false,
        dragging: false,
        scrollWheelZoom: false,
        doubleClickZoom: false
})
      

// function to create map layer
function createLayer(map_id) {
    L.tileLayer("https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}", {
    attribution: "Map data &copy; <a href=\"https://www.openstreetmap.org/\">OpenStreetMap</a> contributors, <a href=\"https://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"https://www.mapbox.com/\">Mapbox</a>",
    maxZoom: 2,
    id: "mapbox.light",
    accessToken: API_KEY
    }).addTo(map_id);
}

createLayer(internet_map)
createLayer(polity_map)
createLayer(corruption_map)
createLayer(freedom_map)


// defining color scales for maps
const colors = ['black','red','orange','lightyellow']
const colors_freedom = ['red','orange','lightyellow']


// function to create colorscale with choropleth
function createChoropleth(geojson,map_id,property,steps,colors) {
    L.choropleth(geojson, {
        valueProperty: property, // which property in the features to use
        scale: colors, // chroma.js scale - include as many as you like
        steps: steps, // number of breaks or steps in range
        mode: 'q', // q for quantile, e for equidistant, k for k-means
        style: {
            color: '#fff', // border color
            weight: 0.5,
            fillOpacity: 0.9
        },
        onEachFeature: function(feature, layer) {
            layer.bindPopup(feature.properties.name)
        }
    
    }).addTo(map_id)
}

// async function to load our GeoJson and create color scale based on property values
async function geo(yearNo) {
    // Getting GeoJSON from our /geojson route    
    const data = await d3.json("/geojson/"+yearNo);
    // console.log(data);

        createChoropleth(data,internet_map,'internet',50,colors)
        createChoropleth(data,polity_map,'polity',20,colors)
        createChoropleth(data,corruption_map,'corruption',50,colors)
        createChoropleth(data,freedom_map,'freedom',3,colors_freedom)
};
