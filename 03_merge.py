import pandas as pd

print("Loading files...")

spotify_df = pd.read_csv("data/songs.csv")

listener_df = pd.read_csv("data/top2000_lastfm.csv")

spotify_df = spotify_df.merge(
    listener_df[
        [
            "track_id",
            "listeners",
            "playcount"
        ]
    ],
    on="track_id",
    how="left"
)

spotify_df["listeners"] = (
    spotify_df["listeners"]
    .fillna(0)
    .astype(int)
)

spotify_df["playcount"] = (
    spotify_df["playcount"]
    .fillna(0)
    .astype(int)
)

spotify_df = spotify_df.sort_values(
    by="playcount",
    ascending=False
)

spotify_df.to_csv(
    "data/spotify_with_lastfm_sorted.csv",
    index=False,
    encoding="utf-8-sig"
)

print(
    "Saved: spotify_with_lastfm_sorted.csv"
)

print(spotify_df.shape)
print(
    spotify_df[
        [
            "track_name",
            "artist_name",
            "playcount"
        ]
    ].head(20)
)