import os
import requests

import argparse

from tqdm import tqdm

import pandas as pd


def get_metadata(
    data_dir: str,
    study_id: str
) -> pd.DataFrame:

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

    return metadata_df


def get_urls(
    df: pd.DataFrame,
    raw: bool
) -> pd.DataFrame:
    df["valid_url"] = df["remote_url"].apply(
        lambda row: f"https://osdr.nasa.gov{row}"
    )

    if raw:
        # Get raw sequence files
        df = df[df["valid_url"].str.endswith("_raw.fastq.gz")]
    else:
        # Select groups of files
        selected_subdirs = [
            "MAGs",
            "predicted-genes",
            "annotations-and-taxonomy"
        ]
        df = df[df["subdirectory"].isin(selected_subdirs)]

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
    parser.add_argument(
        "-r", "--raw",
        help="Whether to get only raw files, excluding the rest.",
        action="store_true"
    )
    args = parser.parse_args()

    metadata_df = get_metadata(
        data_dir=args.data_dir,
        study_id=args.study_id
    )

    # Get URL list
    url_df = get_urls(
        df=metadata_df,
        raw=args.raw
    )

    url_df["valid_url"].to_csv(
        os.path.join(
            args.data_dir,
            f"OSD-{args.study_id}-urls.txt"
        ),
        index=False,
        header=False
    )

    print(f"[INFO] Metadata processed for study ID OSD-{args.study_id}")
