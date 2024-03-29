#!/bin/bash

# Define the working directory
# WARNING: The path must not contain spaces: /home/USERNAME/Photos/2019-01-02_Vacations
# mount an SMB share: sudo mount -t cifs -o username=SBM_USERNAME,gid=LOCAL_GROUP_ID,uid=LOCAL_USER_ID //192.168.200.2/DIRECTORY /mnt/DIRECTORY
# example:            sudo mount -t cifs -o username=tolis,gid=1000,uid=1000 //192.168.200.2/Photos /mnt/Photos
DIRECTORY="/mnt/c/Users/tovle/Desktop/100CANON"
# DIRECTORY="/mnt/photos/2021/TO_ORDER"

if [ ! -d $DIRECTORY ]; then
  echo "No directory" $DIRECTORY
  exit 0
fi
# Check if parameter 1 passed to the script and print the menu -----------------
if [ -z "$1" ]; then
  echo "Pick an option:"
  echo "'1' Rename files based on the capture time (Only cr2 and the side files)"
  echo "'2' Move files to directories based on day"
  echo "'3' Change EXIF info for lens"
  echo "'4' Remove data from EXIF tag 'Software'"
  echo "'5' Export embedded previews from RAW"
  echo "'6' Copy EXIF to .jpg"
  echo "'7' Orphan text_files and .jpg cleanup"
  echo "'8' Delete .jpg with RAW parent"
  echo "'0' All together"
  # TODO: Shift time (UK->GR) $ exiftool -overwrite_original_in_place '-AllDates +=0:0:0 1:0:0' .
  exit 0
fi

# If parameter 2 passed to the script and override the variable DIRECTORY ------
if [ ! "$2" == "" ]; then
  DIRECTORY=$2
fi

echo "Working directory:" $DIRECTORY

function rename_files {
  echo "Rename files bases on the capture time --------------------------------"
  # -r                             Subdirectories processed recursively
  # -v                             Verbose
  # -P                             Preserve file modification date/time
  # -ext cr2                       Only check .cr2 files, non case sensitive
  # -tagsfromfile "%d%f.cr2"       Use metadata from this file. @ represent the original
  # -srcfile %d%f.on1              Process the sidecar file as well, if any. In this case ON1 files
  # -d "%Y%m%d_%H%M%S"             Define the date-time format %Y=year %m=month %d=date %H=hour %M=minute %S=second
  # -FileName                      Define the filename
  #                                  ${CreateDate}
  #                                  ${ShutterCount} (doesn't work for Canon)
  #                                  ${SerialNumber}
  #                                  ${FileNumber}
  #                                  ${ImageSize}
  #                                  The %e represents the extension of the specified FILE, which in this case is cr2
  #                                  The %le same with before but turn to lowercase
  #                                  The %-c means that if two images have the same file name up to this point in the naming
  #                                    process, add "a copy number which is automatically incremented" to give each image a unique
  #                                    name. The "-" before the "c" isn't necessary, but it puts a dash before the copy number
  # -TestName                      Use some dry run (instead of -FileName)
  # -overwrite_original_in_place   Overwrite original by copying tmp file

  # DNG
  # echo "# Change name of the main '*.dng' photos"
  # exiftool -r -P -ext dng -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.dng '-FileName<${CreateDate}.%le' -overwrite_original_in_place "$DIRECTORY"

  # CR2
  # echo "Change name of the sidefile '*.on1' configuration for cr2"
  # exiftool -r -P -ext cr2 -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.on1 '-FileName<${CreateDate}_${FileNumber}%-c.on1' -overwrite_original_in_place "$DIRECTORY"
  # echo "Change name of the sidefile '*.jpg' photos"
  # exiftool -r -P -ext cr2 -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.jpg '-FileName<${CreateDate}_${FileNumber}%-c.jpg' -overwrite_original_in_place "$DIRECTORY"
  # echo "Change name of the sidefile '*.xmp' configuration"
  # exiftool -r -P -ext cr2 -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.xmp '-FileName<${CreateDate}_${FileNumber}%-c.xmp' -overwrite_original_in_place "$DIRECTORY"
  # echo "Change name of the sidefile '*.psd' photos"
  # exiftool -r -P -ext cr2 -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.psd '-FileName<${CreateDate}_${FileNumber}%-c.xmp' -overwrite_original_in_place "$DIRECTORY"
  echo "# Change name of the main '*.cr2' photos"
  exiftool -r -P -ext cr2 -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.cr2 '-FileName<${CreateDate}_${FileNumber}%-c.%le' -overwrite_original_in_place "$DIRECTORY"

  # # JPG
  # echo "Change name of the sidefile '*.on1' configuration for jpg"
  # exiftool -r -P -ext jpg -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.on1 '-FileName<${CreateDate}%-c.on1' -overwrite_original_in_place "$DIRECTORY"
  # echo "Change name of the main '*.jpg' photos (photos from phone, internet, etc)"
  # # If the photo have an error with MakerNotes run this: exiftool -makernotes:all= .
  # # Add check "if does not have parent"
  exiftool -r -P -ext jpg -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.jpg '-FileName<${CreateDate}%-c.%le' -overwrite_original_in_place "$DIRECTORY"

  # # TIF
  # echo "Change name of the sidefile '*.on1' configuration for tif"
  # exiftool -r -P -ext tif -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.on1 '-FileName<${CreateDate}%-c.on1' -overwrite_original_in_place "$DIRECTORY"
  # echo "Change name of the sidefile '*.zip' configuration for tif"
  # exiftool -r -P -ext tif -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.zip '-FileName<${CreateDate}%-c.zip' -overwrite_original_in_place "$DIRECTORY"
  # echo "Change name of the sidefile '*.rar' configuration for tif"
  # exiftool -r -P -ext tif -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.rar '-FileName<${CreateDate}%-c.rar' -overwrite_original_in_place "$DIRECTORY"
  # echo "Change name of the main '*.tif' photos (panorama, hdr, other edit)"
  # exiftool -r -P -ext tif -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.tif '-FileName<${CreateDate}%-c.%le' -overwrite_original_in_place "$DIRECTORY"

  # Video files
  echo "# Change name of the main '*.mov' videos"
  exiftool -r -P -ext mov -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.mov '-FileName<${CreateDate}%-c.%le' -overwrite_original_in_place "$DIRECTORY"
  echo "# Change name of the main '*.mp4' videos"
  exiftool -r -P -ext mp4 -tagsfromfile @ -d '%Y%m%d_%H%M%S' -srcfile %d%f.mp4 '-FileName<${CreateDate}%-c.%le' -overwrite_original_in_place "$DIRECTORY"
}

# TODO: .on1 files does not move
# TODO: On the second run it creates new sub-sub directories
function move_files {
  echo "Move files to directories based on day --------------------------------"
  # NOTICE: It will move all the files that contain EXIF information for CreateDate,
  #         that includes videos, psd, etc
  # -o OUTFILE          Set output file or directory name. If you want to keep the
  #                     original files and at the original location add "-o ."
  # -r                  Subdirectories processed recursively
  # -P                  Preserve file modification date/time
  # -d '%Y-%m-%d'       Define the date-time format %Y=year %m=month %d=date
  # -Directory          Define the directory to move the files
  exiftool -r -P -d '%Y-%m-%d' '-Directory<$DIRECTORY/${CreateDate}' "$DIRECTORY"
}

function exif_lens {
  echo "Change EXIF info for lens ---------------------------------------------"
  # Info
  # -Lens and -LensType are Canon xmp metadata and does not change to Tamron because the have to have "fixed" values
  # defined by Canon. The easiest way to make RAW programs to see the Tamron 24-70mm is to define the -LensModel and make
  # the LensType="Unknown (0)"

  # Tampron
  # example EXIF out of the camera
  # exiftool -T -Lens               24.0 - 70.0 mm
  # exiftool -T -LensInfo           24-70mm f/0
  # exiftool -T -LensModel          24-70mm
  # exiftool -T -FocalLength        24.0 mm
  # exiftool -T -MaxFocalLength     70 mm
  # exiftool -T -MinFocalLength     24 mm
  # exiftool -T -FocalUnits         1/mm
  # exiftool -T -MaxApertureValue   -
  # exiftool -T -MinApertureValue   -
  # exiftool -T -TargetAperture     8
  # exiftool -T -FNumber            8.0
  # exiftool -T -LensType           Canon EF 85mm f/1.2L USM or Sigma or Tamron Lens

  # Samyang
  # Variations of EXIF data based on RAW editor
  # DXO: "Samyang 14mm F2.8 IF ED UMC AE Aspherical"
  # ON1: "Samyang 14mm F2.8 AE ED AS IF UMC"

  totalfiles=$(find "$DIRECTORY" -name '*.CR2' -or -name '*.cr2' | wc -l)
  echo "Total files: "$totalfiles
  counter=1

  # Loop all files in current directory and subdirectories
  for file in $(find "$DIRECTORY" -name '*.CR2' -or -name '*.cr2'); do

    # Find lens model
    # -T          (-table) Output tag values in table form. Equivalent to -t -S -q -f
    # -S          (-veryShort) Very short format. The same as -s2 or two -s options
    # -q          (-quiet) Quiet processing. One -q suppresses normal informational messages
    # -f          (-forcePrint) Force printing of all specified tags
    # -LensModel  EXIF info about lens model
    LENSMODEL=$(exiftool -T -LensModel "$file")

    # If Tamron -----------------------------------------------------------------
    if [[ $LENSMODEL == "Tamron SP 24-70mm f/2.8 Di VC USD" ]]; then
      echo -e $counter/$totalfiles"\tTamron  OK file: \"$file\""
    fi

    # If Samgyang ---------------------------------------------------------------
    if [[ $LENSMODEL == "Samyang 14mm F2.8 AE ED AS IF UMC" ]]; then
      echo -e $counter/$totalfiles"\tSamyang OK file: \"$file\""
    fi

    # If 24-70mm ----------------------------------------------------------------
    if [[ $LENSMODEL == "24-70mm" ]]; then
      echo -e $counter/$totalfiles"\tWorking on Tamron file: \"$file\""
      # Change EXIF information about lens
      # -m                               Ignore minor errors and warnings
      # -overwrite_original_in_place     Overwrite original by copying tmp file
      exiftool -Lens="Tamron SP 24-70mm f/2.8 Di VC USD" \
        -LensModel="Tamron SP 24-70mm f/2.8 Di VC USD" \
        -LensType="Unknown (0)" \
        -m -overwrite_original_in_place "$file"
    fi

    # If no lens info -----------------------------------------------------------
    if [[ $LENSMODEL == "" ]]; then
      echo -e $counter/$totalfiles"\tWorking on Samyang file: \"$file\""
      # Change EXIF information about lens
      # -m                               Ignore minor errors and warnings
      # -overwrite_original_in_place     Overwrite original by copying tmp file
      exiftool -Lens="Samyang 14mm F2.8 AE ED AS IF UMC" \
        -LensModel="Samyang 14mm F2.8 AE ED AS IF UMC" \
        -LensType="Unknown (0)" \
        -FocalLength="14.0 mm" \
        -MaxFocalLength="14.0 mm" \
        -MinFocalLength="14.0 mm" \
        -MaxApertureValue="2.8" \
        -MinApertureValue="22" \
        -TargetAperture="2.8" \
        -FNumber="4" \
        -m -overwrite_original_in_place "$file"
    fi

    counter=$((counter + 1))
  done
}

function remove_exif_software {
  echo "Remove data from EXIF tag 'Software' ----------------------------------"
  # Find all files (even if their name or the their path contain spaces)
  # TODO: more testing
  find "$DIRECTORY" -type f -print0 |
    while IFS= read -rd '' file; do

      # FInd only images
      if [[ $(file -i "$file" | grep -o ': image/') ]]; then
        echo "File: $file"
        # Remove EXIF information about Software
        exiftool -Software="" -overwrite_original_in_place "$file"
      fi

      # Find temporary files
      if [[ "$file" == *_exiftool_tmp ]]; then
        # Print file name
        echo "Deleting: "."$file"
        rm -rf "$file"
      fi

    done
}

function export_previews {
  echo "Export previews from RAW ------------------------------------------------"
  # -r                  Subdirectories processed recursively
  # -b                  Export items to binary
  # -ext cr2            Only check .cr2 files, non case sensitive
  # -PreviewImage       Get the preview jpg from the RAW file
  # -w _preview.jpg     Write the file and append custom test
  exiftool -r -b -ext cr2 -PreviewImage -w .jpg "$DIRECTORY"
}

function exif_to_jpg {
  echo "Copy EXIF to jpgs -----------------------------------------------------"
  totalfiles=$(find "$DIRECTORY" -name '*.CR2' -or -name '*.cr2' | wc -l)
  echo "Total files: "$totalfiles
  counter=1

  # Loop all files in current directory and subdirectories
  for file in $(find "$DIRECTORY" -name '*.CR2' -or -name '*.cr2'); do

    # Create the path for the jpgs
    filejpg=$(echo $file | sed 's/...$/jpg/')
    # Print info
    echo -e $counter/$totalfiles"\tCopping EXIF from \"$file\" to \"$filejpg\""

    # -TagsFromFile                   Copy EXIF data form $file to $filejpg
    # -overwrite_original_in_place    Overwrite original by copying tmp file
    exiftool -overwrite_original_in_place -TagsFromFile $file $filejpg

    counter=$((counter + 1))
  done
}

function orphan_cleanup {
  # Create deleted_files directory
  if [ ! -d ./orphan_deleted_files ]; then
    mkdir ./orphan_deleted_files
  fi

  # -type f    Find only files
  # -print0    Always print the exact filename, unchanged, even if the output is going to a terminal
  find "$DIRECTORY" -type f -print0 |
    # IFS           Internal field separator. It is used by the shell to determine how to do word splitting
    # read          Read a line from the standard input and split it into fields
    # -r            do not allow backslashes to escape any characters
    # -d delim      continue until the first character of DELIM is read, rather than newline
    while IFS= read -rd '' file; do

      # Find filetype
      filetype=$(file -i "$file")

      # Find text files
      if [[ $(echo "$filetype" | grep ': text/plain; charset=us-ascii') ]]; then
        fileraw=$(echo $file | sed 's/...$/cr2/')
        if [ ! -f "$fileraw" ]; then
          echo "RAW file not found! $fileraw" 2>&1 | tee -a ./orphan_deleted_files/orphan_deleted_files.log
          mv "$file" ./orphan_deleted_files
        fi
      fi

      # # Find jpg images
      if [[ $(echo "$filetype" | grep ': image/jpeg; charset=binary') ]]; then
        fileraw=$(echo $file | sed 's/...$/cr2/')
        if [ ! -f "$fileraw" ]; then
          echo "RAW file not found! $fileraw" 2>&1 | tee -a ./orphan_deleted_files/orphan_deleted_files.log
          mv "$file" ./orphan_deleted_files
        fi
      fi

    done
}

function delete_jpg_with_parent {
  # Create deleted_files directory
  if [ ! -d ./delete_jpg_with_parent ]; then
    mkdir ./delete_jpg_with_parent
  fi
  # -type f    Find only files
  # -print0    Always print the exact filename, unchanged, even if the output is going to a terminal
  find "$DIRECTORY" -type f -print0 |
    # IFS           Internal field separator. It is used by the shell to determine how to do word splitting
    # read          Read a line from the standard input and split it into fields.
    # -r            do not allow backslashes to escape any characters
    # -d delim      continue until the first character of DELIM is read, rather than newline
    while IFS= read -rd '' file; do

      # Find filetype
      filetype=$(file -i "$file")

      # Find text files
      if [[ $(echo "$filetype" | grep ': image/jpeg; charset=binary') ]]; then
        fileraw=$(echo $file | sed 's/...$/cr2/')
        if [ -f "$fileraw" ]; then
          echo "Parent RAW file found, deleting jpg: $fileraw" 2>&1 | tee -a ./delete_jpg_with_parent/delete_jpg_with_parent.log
          mv "$file" ./delete_jpg_with_parent
        fi
      fi

    done
}

function all_together {
  echo "Run all functions together --------------------------------------------"
  rename_files
  move_files
  exif_lens
  remove_exif_software
  # export_previews
  exif_to_jpg
  orphan_cleanup
  # delete_jpg_with_parent
}

# Menu -------------------------------------------------------------------------
case "$1" in

1) rename_files ;;
2) move_files ;;
3) exif_lens ;;
4) remove_exif_software ;;
5) export_previews ;;
6) exif_to_jpg ;;
7) orphan_cleanup ;;
8) delete_jpg_with_parent ;;
0) all_together ;;
esac
