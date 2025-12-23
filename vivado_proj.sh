source ~/xilinx/Vivado/2021.2/settings64.sh
source ~/.bashconfigs

PROJ_NAME="$1"
TOP_MODULE="$2"

PROJ_DIR="$(pwd)/vivado_proj"
PART_OR_BOARD="xcu50-fsvh2104-2-e"

mkdir -p "$PROJ_DIR"

echo "=== Vivado Project Generator ==="
echo " Project Name : $PROJ_NAME"
echo " Top Module   : $TOP_MODULE"
echo " Device       : $PART_OR_BOARD"
echo " Target Dir   : $PROJ_DIR"
echo "================================"

vivado -mode batch -source ./create_proj.tcl -tclargs \
  "$PROJ_NAME" "$PROJ_DIR" "$PART_OR_BOARD" "$TOP_MODULE"

