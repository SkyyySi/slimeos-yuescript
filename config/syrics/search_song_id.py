#!/usr/bin/env python3
from syrics.api import Spotify
import sys
import json


def get_song_data(client: Spotify, title: str) -> dict:
	return client.search(title, type="track", limit=1)["tracks"]["items"][0]


def main(argv: list[str]):
	with open(argv[0]) as file:
		config = json.load(file)

	client = Spotify(config["sp_dc"])
	song = get_song_data(client, argv[1])
	return song["id"]


if __name__ == "__main__":
	print(main(sys.argv[1:]))
