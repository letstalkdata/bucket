#
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
#
bucket_show_profile(){
    echo "+--------+-----------+-----+------------+"
    echo "|  Type  |  Profile  | cpu | memory(GB) |"
    echo "|--------|-----------|-----|------------|"
    echo "| System |  tiny     |  1  |     1      |"
    echo "| System |  miny     |  1  |     2      |"
    echo "| System |  miny2    |  2  |     2      |"
    echo "| System |  regular  |  2  |     2      |"
    echo "| System |  regular2 |  2  |     4      |"
    echo "| System |  heavy    |  4  |     8      |"
    echo "| System |  heavy2   |  8  |     16     |"
    echo "| System |  heavy3   |  8  |     32     |"
    echo "+--------+-----------+-----+------------+"
}