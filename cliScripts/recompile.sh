# get current dir with pwd
CURRENT_DIR=$(pwd)
DB_DIR="/home/matth/Winter2025/CSCD43/A1/postgresql-17.2" # Set the directory of the PostgreSQL source code
MAKE_CLEAN=false

# Parse command line options
while getopts "h" opt; do
  case $opt in
    h) 
      # Clean
      MAKE_CLEAN=true
      ;;
    *)
      echo "Usage: $0 [-h]"
      exit 1
      ;;
  esac
done

cd $DB_DIR
echo $(pwd)
if [ "$MAKE_CLEAN" = true ]; then
  echo "Cleaning the PostgreSQL source code..."
  make clean
  if [ $? -ne 0 ]; then
    echo "Error: Failed to clean the PostgreSQL source code!"
    exit 1
  fi
fi

echo "Uninstalling the PostgreSQL source code..."]
sudo make uninstall
if [ $? -ne 0 ]; then
  echo "Error: Failed to uninstall the PostgreSQL source code!"
  exit 1
fi
# echo "Configuring the PostgreSQL source code..."
# ./configure
# if [ $? -ne 0 ]; then
#   echo "Error: Failed to configure the PostgreSQL source code!"
#   exit 1
# fi
echo "Recompiling the PostgreSQL source code..."
make
if [ $? -ne 0 ]; then
  echo "Error: Failed to recompile the PostgreSQL source code!"
  exit 1
fi
echo "Installing the PostgreSQL source code..."
sudo make install
if [ $? -ne 0 ]; then
  echo "Error: Failed to install the PostgreSQL source code!"
  exit 1
fi

echo "PostgreSQL has been recompiled and installed successfully!"
cd $CURRENT_DIR