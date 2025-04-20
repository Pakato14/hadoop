#!/bin/bash
# Script para automatizar o MapReduce no Hadoop Streaming

# Diretórios
CSV_DIR="/dados/precos_diesel"            # Local onde os arquivos CSV estão no container
HDFS_INPUT="/user/hadoop/csv_input"       # Diretório no HDFS de entrada
HDFS_OUTPUT="/user/hadoop/resultado_combustivel" # Saída do MapReduce

# Caminho completo para os scripts
MAPPER="/tmp/mapper.py"
REDUCER="/tmp/reducer.py"
PYTHON_BIN="/usr/bin/python3"

# Passo 1: Subir os arquivos CSV para o HDFS
echo "[*] Enviando arquivos CSV para o HDFS..."
hdfs dfs -rm -r -f "$HDFS_INPUT"
hdfs dfs -mkdir -p "$HDFS_INPUT"
hdfs dfs -put "$CSV_DIR"/*.csv "$HDFS_INPUT"

# Passo 2: Executar o job Hadoop Streaming
echo "[*] Removendo saída anterior..."
hdfs dfs -rm -r -f "$HDFS_OUTPUT"

echo "[*] Executando MapReduce..."
hadoop jar "$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar" \
  -input "$HDFS_INPUT" \
  -output "$HDFS_OUTPUT" \
  -mapper "$PYTHON_BIN $MAPPER" \
  -reducer "$PYTHON_BIN $REDUCER" \
  -file "$MAPPER" \
  -file "$REDUCER"

# Passo 3: Mostrar o resultado final
echo "[*] Resultado do MapReduce:"
hdfs dfs -cat "$HDFS_OUTPUT/part-00000"
