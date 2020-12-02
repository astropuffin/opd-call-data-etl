#!/bin/bash
cat OPD_PublicCallData_2019.csv | parallel --header : --pipe -N1000 'cat > splits/data-{#}.csv'
