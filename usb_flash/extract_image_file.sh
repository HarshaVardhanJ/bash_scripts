#!/usr/bin/env bash
#
#: Title        : extract_image_file.sh
#: Date         : 04-Mar-2019
#: Author       : "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1
#: Description  : Gets the image file and extracts it if it's compressed.
#                 The extracted file is checked if it's of an acceptable
#                 format/type. The absolute path to the extracted(if it's 
#                 compressed) image file is returned. If the file is not 
#                 compressed, the image file is checked if it's of an
#                 acceptable format/type. Then, the absolute path to the
#                 image file is returned
#                
#: Options      : Requires one argument, namely the path to the image file.
#: Usage        :	
################


