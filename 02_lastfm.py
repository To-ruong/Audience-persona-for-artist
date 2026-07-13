import requests
import pandas as pd
import time

API_KEY = "5dbecc9415d13ff51e9499cdc7fc1847"

print("Loading top2000_tracks.csv...")

top2000 = pd.read_csv("data/top2000_tracks.csv")

results = []

found = 0
not_found = 0

for _, row in top2000.iterrows():

    track = str(row["track_name"]).strip()
    artist = str(row["artist_name"]).strip()

    try:

        search_response = requests.get(
            "https://ws.audioscrobbler.com/2.0/",
            params={
                "method": "track.search",
                "track": track,
                "api_key": API_KEY,
                "format": "json",
                "limit": 1
            },
            timeout=10
        )

        search_data = search_response.json()

        matches = (
            search_data
            .get("results", {})
            .get("trackmatches", {})
            .get("track", [])
        )

        if not matches:
            not_found += 1
            continue

        if isinstance(matches, dict):
            matches = [matches]

        matched_track = matches[0]["name"]
        matched_artist = matches[0]["artist"]

        info_response = requests.get(
            "https://ws.audioscrobbler.com/2.0/",
            params={
                "method": "track.getInfo",
                "track": matched_track,
                "artist": matched_artist,
                "api_key": API_KEY,
                "format": "json"
            },
            timeout=10
        )

        info_data = info_response.json()

        if "track" not in info_data:
            not_found += 1
            continue

        results.append({
            "track_id": row["track_id"],
            "track_name": row["track_name"],
            "artist_name": row["artist_name"],
            "listeners": int(info_data["track"]["listeners"]),
            "playcount": int(info_data["track"]["playcount"])
        })

        found += 1

        if found % 50 == 0:
            print(
                f"Found: {found} | Not Found: {not_found}"
            )


    except Exception as e:

        print(
            f"ERROR: {track} - {artist}"
        )
        print(e)

        not_found += 1

print("\nDone")
print("Found:", found)
print("Not Found:", not_found)

listener_df = pd.DataFrame(results)

listener_df.to_csv(
    "data/top2000_lastfm.csv",
    index=False,
    encoding="utf-8-sig"
)

print(listener_df.shape)
print("Saved: top2000_lastfm.csv")