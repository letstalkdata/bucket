#!/bin/bash
#
gluster volume create xfsvol1 replica 3 g1-gluster1:/mnt/dvc1/brick/1 g1-gluster2:/mnt/dvc1/brick/1 g1-gluster3:/mnt/dvc1/brick/1 g1-gluster4:/mnt/dvc1/brick/1 g1-gluster5:/mnt/dvc1/brick/1 g1-gluster6:/mnt/dvc1/brick/1 
gluster volume start xfsvol1
gluster volume status xfsvol1
gluster volume info xfsvol1
