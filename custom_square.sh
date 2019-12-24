#! /bin/bash

outersize=128
border=1
bordercolor=red
background=black

innersize=$(($outersize - 2 * $border))
size="${innersize}x${innersize}"
image_file_ext='--file-filter=image|*.png *.jpg *.PNG *.JPG'
options="-alpha set -define bmp:format=bmp4"
cube_option="-resize $size -gravity center -background $background -extent $size -border $border -bordercolor $bordercolor"
#options=" -alpha set -define bmp:format=bmp3 -define bmp3:alpha=true "
#options=" -alpha set "
ext=.bmp

echo $cube_option

tmp=$(mktemp -d)

# create a black image
convert -size ${outersize}x${outersize} xc:Black $tmp/black$ext

sides_filename="$(zenity --file-selection "$(pwd)" "$image_file_ext" --title "Image sur les cotés")"
if [ -z "$sides_filename" ] ; then 	
	zenity --error --text "Pas de coté, pas de cube"
    exit
fi

top_filename="$(zenity --file-selection "$(pwd)" "$image_file_ext" --title "Image sur le sommet, Annuler pour idem")" 
if [ $? -gt 0 ] ; then 
	top_filename="$sides_filename"
	bottom_filename="$top_filename"
else
 bottom_filename="$(zenity --file-selection "$(pwd)" "$image_file_ext" --title "Image sur le bas, Annuler pour idem")" 
 if [ $? -gt 0 ] ; then 
	bottom_filename="$top_filename"
 fi 
fi

er=1;
while [ $er -gt 0 ]
do 
    inv_filename="$(zenity --file-selection "$(pwd)" "$image_file_ext" --title "Image pour inventaire")"
    er=$?
done


echo "side '$sides_filename'" | cat -A
echo "top '$top_filename'"|cat -A
echo "bottom '$bottom_filename'" | cat -A
if convert $cube_option              $sides_filename  $options $tmp/right$ext  \
&& convert $cube_option -rotate 270 $sides_filename  $options $tmp/back$ext   \
&& convert $cube_option -rotate 180 $sides_filename  $options $tmp/left$ext   \
&& convert $cube_option -rotate 90  $sides_filename  $options $tmp/front$ext  \
&& convert $cube_option             $top_filename    $options $tmp/top$ext    \
&& convert $cube_option -rotate 180 $bottom_filename $options $tmp/bottom$ext \
&& convert $cube_option             $inv_filename    $options $tmp/inv$ext
then
	 true
else
	zenity --error --text "Cannot convert into $size"
	exit
fi

convert -append $tmp/black$ext $tmp/front$ext  $tmp/black$ext $tmp/black$ext $options $tmp/1$ext
convert -append $tmp/left$ext  $tmp/top$ext    $tmp/right$ext $tmp/black$ext $options $tmp/2$ext
convert -append $tmp/black$ext $tmp/back$ext   $tmp/black$ext $tmp/black$ext $options $tmp/3$ext
convert -append $tmp/black$ext $tmp/bottom$ext $tmp/black$ext $tmp/inv$ext   $options $tmp/4$ext

convert +append $tmp/[1-4]$ext final$ext

rm -f $tmp/*
rmdir $tmp
