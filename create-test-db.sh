git clone --recursive https://github.com/lovasoa/TPCH-sqlite.git
cd TPCH-sqlite
make
snap install sqlitebrowser
sqlitebrowser TPC-H.db
