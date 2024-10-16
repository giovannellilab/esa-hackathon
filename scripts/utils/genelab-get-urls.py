import os
import requests

import argparse

from tqdm import tqdm

import pandas as pd


def get_metadata(
    data_dir: str,
    study_id: str
) -> None:

    # Query GeneLab
    base_url = "https://osdr.nasa.gov/osdr/data/osd/files/{}"
    response = requests.get(base_url.format(study_id)).json()

    # Retrieve information from the response
    metadata_df = pd.DataFrame(
        response["studies"][f"OSD-{study_id}"]["study_files"]
    )

    metadata_df.to_csv(
        os.path.join(
            data_dir,
            f"OSD-{study_id}-metadata.csv"
        ),
        index=False
    )

    # Select groups of files
    selected_subdirs = [
        "MAGs",
        "predicted-genes",
        "annotations-and-taxonomy"
    ]
    metadata_df = metadata_df[
        metadata_df["subdirectory"].isin(selected_subdirs)
    ]

    # Get URL list
    url_df = get_urls(metadata_df)
    url_df["valid_url"].to_csv(
        os.path.join(
            data_dir,
            f"OSD-{study_id}-urls.txt"
        ),
        index=False,
        header=False
    )

    return None


def get_urls(df: pd.DataFrame) -> pd.DataFrame:
    df["valid_url"] = df["remote_url"].apply(
        lambda row: f"https://osdr.nasa.gov{row}"
    )

    # Remove unused -genes.fasta and -genes.fasta files
    df = df[~df["valid_url"].str.contains("-genes\.fa")]

    return df


if __name__ == "__main__":

    parser = argparse.ArgumentParser("theseus")
    parser.add_argument(
        "-d", "--data-dir",
        help="Directory containing all files.",
        type=str
    )
    parser.add_argument(
        "-s", "--study-id",
        help="Study ID to process.",
        type=str
    )
    args = parser.parse_args()

    get_metadata(
        data_dir=args.data_dir,
        study_id=args.study_id
    )

    print(f"[*] Processed study ID OSD-{args.study_id}")
