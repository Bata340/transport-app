from fastapi import FastAPI
from zipfile import ZipFile
from typing import List
from dotenv import load_dotenv
import requests, io, pandas as pd, json, os
load_dotenv(".env")
app = FastAPI()
paramsReq=dict()
paramsReq["client_id"] = os.getenv("api_client_id")
paramsReq["client_secret"] = os.getenv("api_client_secret")
reqUrl = "https://"+os.getenv("api_url")+"/colectivos/feed-gtfs"
zipReq = requests.get(reqUrl, params=paramsReq, stream=True)
with ZipFile(io.BytesIO(zipReq.content)) as zip:
    df_routes = pd.read_csv(zip.open("routes.txt"))
    df_trips = pd.read_csv(zip.open("trips.txt"))
    df_stops_times = pd.read_csv(zip.open("stop_times.txt"))
    df_stops = pd.read_csv(zip.open("stops.txt"))


@app.post("/buses/stations/")
async def get_stations_from_ramales(ramales: List[int]):
    df_ramales = pd.array(ramales)
    df_routes_ramales = df_routes[df_routes["route_id"].isin(df_ramales)]
    df_routes_ramales = df_routes_ramales.loc[:,["route_id", "route_short_name"]]
    df_trips_ramales = df_trips[df_trips["route_id"].isin(df_ramales)]
    df_trips_ramales = df_trips_ramales.loc[:,["route_id", "trip_id"]]
    df_stops_times_trips = df_stops_times[df_stops_times["trip_id"].isin(df_trips_ramales.loc[:,"trip_id"])]
    df_stops_times_trips = df_stops_times_trips.loc[:,["trip_id", "stop_sequence", "stop_id"]]
    df_stops_ramales = df_stops[df_stops["stop_id"].isin(df_stops_times_trips.loc[:,"stop_id"])]
    df_stops_ramales = df_stops_ramales.loc[:,["stop_id", "stop_name", "stop_lat", "stop_lon"]]
    merged_df = pd.merge(df_routes_ramales, df_trips_ramales, on='route_id')
    merged_df = pd.merge(merged_df, df_stops_times_trips, on="trip_id")
    merged_df = pd.merge(merged_df, df_stops_ramales, on="stop_id")
    merged_df['json'] = merged_df.apply(lambda x: x.to_json(), axis=1)
    return json.dumps(merged_df.loc[:,"json"].tolist())

