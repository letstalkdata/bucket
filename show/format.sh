awk 'BEGIN {}
  {print "---------------"; for(i = 1; i <= NF; i++) print $i }
  END {}' db/ns.csv