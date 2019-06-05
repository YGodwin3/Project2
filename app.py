import os

import pandas as pd
import numpy as np

import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine

from flask import Flask, jsonify, render_template
from flask_sqlalchemy import SQLAlchemy

import json
import requests

app = Flask(__name__)


#################################################
# Database Setup
#################################################

app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///db/internet_freedom.sqlite"
db = SQLAlchemy(app)

# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(db.engine, reflect=True)

# Save references to each table
InternetFreedom = Base.classes.internet_freedom

test1 = Base.classes.keys()

print(test1)



@app.route("/")
def index():
    # return index.html
    return render_template("index.html")

@app.route("/years")
def years():
    """Return a list of years."""

    # Use Pandas to perform the sql query
    stmt = db.session.query(InternetFreedom).statement
    df = pd.read_sql_query(stmt, db.session.bind)

    # Filter data for drop down
    years_data = pd.DataFrame(df.loc[(df["YEAR_NO"] >= 2012) , "YEAR_NO"].unique(), columns = ["YEAR_NO"])
    years_data = years_data.sort_values(by="YEAR_NO")
    data = years_data.YEAR_NO.values.tolist()
    # Return a list of years after 2012 for drop down
    return jsonify(data)


@app.route("/country/<input_country_cd>")
def countryData(input_country_cd):
    stmt = db.session.query(InternetFreedom).statement
    df = pd.read_sql_query(stmt, db.session.bind)

    # Filter the data based on country_cd
    country_data = df.loc[ (df["COUNTRY_CD"] == input_country_cd) & (df["YEAR_NO"] >= 2012) & (df["YEAR_NO"] <= 2017), ["COUNTRY_CD","COUNTRY_NM","YEAR_NO", "INTERNET_USER_RATE", "POLITY_SCORE", "REGIME_STATUS", "FREEDOM_IND","FREEDOM_STATUS", "CORRUPTION_INDEX"]].sort_values(by='YEAR_NO', ascending=True)

    # Format the data to send as json
    data = {
        "COUNTRY_CD": country_data.COUNTRY_CD.values.tolist(),
        "COUNTRY_NM": country_data.COUNTRY_NM.values.tolist(),
        "YEAR_NO": country_data.YEAR_NO.values.tolist(),
        "INTERNET_USER_RATE": country_data.INTERNET_USER_RATE.values.tolist(),
        "POLITY_SCORE": country_data.POLITY_SCORE.tolist(),
        "REGIME_STATUS": country_data.REGIME_STATUS.tolist(),
        "FREEDOM_IND": country_data.FREEDOM_IND.tolist(),
        "FREEDOM_STATUS": country_data.FREEDOM_STATUS.tolist(),
        "CORRUPTION_INDEX": country_data.CORRUPTION_INDEX.tolist()
    }
    return jsonify(data)


@app.route("/data/<year_no>")
def yearData(year_no):
    stmt = db.session.query(InternetFreedom).statement
    df = pd.read_sql_query(stmt, db.session.bind)

    # Filter the data based on year
    country_data = df.loc[ df["YEAR_NO"] == int(year_no), ["COUNTRY_CD","COUNTRY_NM","YEAR_NO", "INTERNET_USER_RATE", "POLITY_SCORE", "REGIME_STATUS","FREEDOM_IND", "FREEDOM_STATUS", "CORRUPTION_INDEX"]].sort_values(by='YEAR_NO', ascending=True)

    # Format the data to send as json
    data = {
        "COUNTRY_CD": country_data.COUNTRY_CD.values.tolist(),
        "COUNTRY_NM": country_data.COUNTRY_NM.values.tolist(),
        "YEAR_NO": country_data.YEAR_NO.values.tolist(),
        "INTERNET_USER_RATE": country_data.INTERNET_USER_RATE.values.tolist(),
        "POLITY_SCORE": country_data.POLITY_SCORE.tolist(),
        "REGIME_STATUS": country_data.REGIME_STATUS.tolist(),
        "FREEDOM_IND": country_data.FREEDOM_IND.tolist(),
        "FREEDOM_STATUS": country_data.FREEDOM_STATUS.tolist(),
        "CORRUPTION_INDEX": country_data.CORRUPTION_INDEX.tolist()
    }
    return jsonify(data)


@app.route("/data")
def allData():
    stmt = db.session.query(InternetFreedom).statement
    df = pd.read_sql_query(stmt, db.session.bind)

    # create a list of dictionaries to display all our data 
    list_of_dict= df.T.to_dict().values()
    return jsonify(list(list_of_dict))

@app.route("/geojson/<year_no>")
def geojson(year_no):
    stmt = db.session.query(InternetFreedom).statement
    our_df = pd.read_sql_query(stmt, db.session.bind)
    our_df = our_df[our_df["YEAR_NO"] == int(year_no)]

    # get GeoJson for countries borders
    url = "https://raw.githubusercontent.com/johan/world.geo.json/master/countries.geo.json"
    response = requests.get(url)
    response_json = response.json()

    # add values from our data to the GeoJson properties key
    for country in response_json["features"]:
        for value in our_df.values:
            if country["id"] == value[1]:
                country["properties"]["internet"] = value[4]
                country["properties"]["polity"] = value[5]
                country["properties"]["corruption"] = value[9]
                country["properties"]["freedom"] = value[7]
    return jsonify(response_json)



if __name__ == "__main__":
    # app.run()
    app.run(debug=True, use_reloader=True)

