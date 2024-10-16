import os
import glob

import argparse


def move_files(data_dir: str) -> None:
    file_pattern = "-contig-coverage-and-tax.tsv"
    glob_pattern = os.path.join(
        data_dir,
        f"*{file_pattern}"
    )

    for filename in glob.glob(glob_pattern):
        sample_name = filename.replace(file_pattern, "")
        os.makedirs(sample_name, exist_ok=True)

        for sample_file in glob.glob(f"{sample_name}*"):
            if not os.path.isdir(sample_file):
                os.rename(
                    sample_file,
                    os.path.join(
                        sample_name,
                        os.path.split(sample_file)[-1]
                    )
                )

        print("[+] Processed sample:", os.path.split(sample_name)[-1])

    return None


if __name__ == "__main__":

    parser = argparse.ArgumentParser("theseus")
    parser.add_argument(
        "-d", "--data-dir",
        help="Directory containing all files.",
        type=str
    )
    args = parser.parse_args()

    move_files(args.data_dir)

    print(f"[*] Files reorganized successfully!")
