import os
import requests

import argparse

from tqdm import tqdm

import pandas as pd


def get_species(
    data_dir: str,
    study_id: str
) -> None:
    metadata_df = pd.read_csv(
        os.path.join(
            data_dir,
            f"GLDS-{study_id}_GMetagenomics_MAGs-overview.tsv"
        ),
        sep="\t"
    )

    # Replace extra "_A" and "_B"
    metadata_df["species"] = metadata_df["species"]\
        .str.replace("_A", "")\
        .str.replace("_B", "")

    metadata_df["species"].dropna().drop_duplicates().to_csv(
        os.path.join(
            data_dir,
            f"OSD-{study_id}-species.txt"
        ),
        index=False,
        header=False
    )

    return None


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

    get_species(
        data_dir=args.data_dir,
        study_id=args.study_id
    )

    print(f"[*] Species retrieved for study ID OSD-{args.study_id}")
