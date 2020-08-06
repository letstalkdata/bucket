awk 'BEGIN {}
  {print "---------------"; for(i = 1; i <= NF; i++) print $i }
  END {}' $BUCKET_HOME/db/ns.csv