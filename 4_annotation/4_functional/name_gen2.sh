#!/bin/bash
#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@

if [ $# -eq 0 ]
then
	printf "No arguments supplied. Input arguments as follows:\t./name_gen.sh <mapping_output> <dict_path> <threads>\n\nWhere:\n\t<mapping_output> =\tPath to Blast2Go Mapping Export\n\t<dict_path> =\tPath to write dictionary of gene names to. WILL OVERWRITE.\n\t<threads =\tNumber of threads to use>\n"
fi

mapping_output=$1
dict_path=$2
threads=$3
#~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~%~~~~~@
rm ${dict_path} commands.tmp

g_count=$(awk '{print $1}' ${mapping_output} | awk -F'g' '{print $2}' | sort -V | tail -n1)

step=$((${g_count}/${threads}))
start_val=1


for thread in $(seq ${threads}); do
	echo "for gene in \$( seq ${start_val} $(( ${step} * ${thread} )) );do name=\$(awk -v gene='g'\${gene}'\t' -F'GN=' '\$1 ~ gene {print \$2}' ${mapping_output} | awk '!/^LOC/ {a[\$1]++; if(m<a[toupper(\$1)]){m=a[toupper(\$1)];s[m]=toupper(\$1)}} END{print s[m]}'); if [ -z \${name} ]; then name='g'\${gene}; fi; printf 'g'\${gene}'\t'\${name}'\n' >> ${dict_path}; done" >> commands.tmp
	start_val=$((${step} * ${thread} + 1))
done

echo "for gene in \$( seq ${start_val} ${g_count} );do name=\$(awk -v gene='g'\${gene}'\t' -F'GN=' '\$1 ~ gene {print \$2}' ${mapping_output} | awk '!/^LOC/ {a[\$1]++; if(m<a[toupper(\$1)]){m=a[toupper(\$1)];s[m]=toupper(\$1)}} END{print s[m]}'); if [ -z \${name} ] || [[ \${name} =~ ^LOC ]]; then name='g'\${gene}; fi; printf 'g'\${gene}'\t'\${name}'\n' >> ${dict_path}; done" >> commands.tmp

parallel --jobs ${threads} < commands.tmp

sort -Vo ${dict_path} ${dict_path}

awk 'BEGIN {named=0;unamed=0} { if( $2 !~ /g/ ){ named+=1 } else { unamed+=1 } } END {printf "#~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~@\nTotal genes labeled:\t\t"unamed+named"\nPercent named successfully:\t"(named/(named+unamed))*100"\n#~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~%%~~~~~@\n" }' ${dict_path}

rm commands.tmp
