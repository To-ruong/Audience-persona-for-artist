import pandas as pd

print("Loading songs.csv...")

spotify_df = pd.read_csv(r"data\songs.csv")

top2000 = (
    spotify_df
    .groupby(
        ["track_id", "track_name", "artist_name"],
        as_index=False
    )
    .agg({
        "stream_count": "sum",
        "popularity": "max"
    })
    .sort_values(
        by="stream_count",
        ascending=False
    )
    .head(2000)
)

top2000.to_csv(
    "data/top2000_tracks.csv",
    index=False,
    encoding="utf-8-sig"
)

print("Saved: top2000_tracks.csv")
print("Shape:", top2000.shape)
print(top2000.head())