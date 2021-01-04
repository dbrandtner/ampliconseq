BEGIN {OFS="\t"} {if($4 >= 283) { print $1,$2,$3,$4,$5,$6} }
