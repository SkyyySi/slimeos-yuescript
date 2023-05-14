#!/usr/bin/env python3
from syrics.api import Spotify
from typing import Optional
import sys
import json


# -> tuple[bool, dict]
def get_song_data(client: Spotify, title: str):
	tracks: list = client.search(title, type="track", limit=1)["tracks"]["items"]

	if len(tracks) < 1:
		return (False, None)

	return (True, tracks[0])


def main(argv: list[str]):
	with open(argv[0]) as file:
		config = json.load(file)

	client = Spotify(config["sp_dc"])
	found, song = get_song_data(client, argv[1])
	return song["id"] if found else ""


if __name__ == "__main__":
	print(main(sys.argv[1:]))
