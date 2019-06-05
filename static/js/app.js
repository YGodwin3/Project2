var dataYear;

async function buildCharts(yearNo) {

  // load json for data in each year
    dataYear = await d3.json("/data/"+yearNo);
    const markerSymbols = dataYear.FREEDOM_IND.map(i => {switch(i){case -1: return "triangle-down"; break; case 1: return "triangle-up"; break; default: return "circle";}} );

    // Bubble Chart using the data
    const trace = {
      x: dataYear.CORRUPTION_INDEX,
      y: dataYear.INTERNET_USER_RATE,
      mode: "markers",
      marker: {
        size: 16,
        symbol: markerSymbols,
        opacity: .6,
        color: dataYear.POLITY_SCORE,
        colorscale: 'Hot',
        colorbar: {
          title: "Polity Score"
        },
        line: { 
          color: 'rgb(0,0,0)',
          width: 1
        },
      },
      text: dataYear.COUNTRY_NM
    };

    const data = [trace];

    const layout = {
      margin:{
        l: 50,
        t: 0,
      },
      xaxis: {
        title: 'Corruption Index',
        rangemode: 'tozero',
        autorange: true
      },
      yaxis: {
        title: 'Internet User Rate',
        autorange: true
      },
      hovermode: "closest"
    };

    Plotly.newPlot('bubble', data, layout);
  
};

function init() {
  // Grab a reference to the dropdown select element
   const selector = d3.select("#selYear");
  
  // Use the list of sample names to populate the select options
  d3.json("/years").then((yearslist) => {
    yearslist.forEach((year) => {
      selector
        .append("option")
        .text(year)
        .property("value", year);
    });

    // Use the first sample from the list to build the initial plots
    const firstYear = yearslist[0];
    buildCharts(firstYear);
    geo(firstYear);
    // buildMetadata(firstYear);
  });
}

function optionChanged(newYear) {
  // Fetch new data each time a new sample is selected
  buildCharts(newYear);
  geo(newYear);
}

// Initialize the dashboard
init();
