#!/bin/bash

set -e  # Para parar em caso de erro

# === MAP PHASE ===

echo "[🧹] Limpando containers e imagens Docker..."
docker stop $(docker ps -q) || true
docker container prune -f

echo "[📦] Criando o ambiente Docker Hadoop..."
docker build -t renci/hadoop:2.9.0 ./2.9.0/
docker images

echo "[🧱] Build do cluster com Docker Compose..."
docker-compose build

echo "[🚀] Subindo cluster Hadoop..."
docker-compose -f 5-node-cluster.yml up -d --remove-orphans
docker-compose ps

# === SHUFFLE & SORT PHASE ===

# Função para aguardar o Hadoop NameNode
wait_for_namenode() {
  echo "[⏳] Aguardando Hadoop NameNode ficar disponível..."
  until docker exec namenode runuser -l hadoop -c "hdfs dfsadmin -report" >/dev/null 2>&1; do
    printf "."
    sleep 2
  done
  echo -e "\n[✅] NameNode está disponível!"
}

wait_for_namenode

echo "[📂] Verificando se arquivos CSV estão disponíveis no container 'namenode'..."
docker exec -it namenode ls /dados

echo "[📁] Criando diretório no HDFS (caso não exista)..."
docker exec namenode runuser -l hadoop -c $'hdfs dfs -mkdir -p /user/hadoop/csv_input'

echo "[📤] Copiando arquivos CSV para o HDFS..."
docker exec namenode runuser -l hadoop -c $'hdfs dfs -put /dados/*.csv /user/hadoop/csv_input/'

echo "[🔍] Verificando arquivos no HDFS..."
docker exec namenode runuser -l hadoop -c $'hdfs dfs -ls /user/hadoop/csv_input'

# === REDUCE PHASE ===

echo "[📜] Enviando scripts mapper e reducer para o container..."
docker cp scripts/mapper.py namenode:/tmp/mapper.py
docker cp scripts/reducer.py namenode:/tmp/reducer.py

echo "[🔐] Ajustando permissões..."
docker exec namenode chmod +x /tmp/mapper.py /tmp/reducer.py

echo "[🗑️] Removendo saída antiga (se existir)..."
docker exec namenode runuser -l hadoop -c 'hdfs dfs -rm -r -f /user/hadoop/resultado_combustivel'

echo "[⚙️] Executando MapReduce com Hadoop Streaming..."
docker exec namenode runuser -l hadoop -c '
  hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
    -input /user/hadoop/csv_input \
    -output /user/hadoop/resultado_combustivel \
    -mapper "/usr/bin/python3 /tmp/mapper.py" \
    -reducer "/usr/bin/python3 /tmp/reducer.py" \
    -file /tmp/mapper.py \
    -file /tmp/reducer.py
'

# === OUTPUT ===

echo "[📈] Resultado final do processamento:"
docker exec namenode runuser -l hadoop -c 'hdfs dfs -cat /user/hadoop/resultado_combustivel/part-00000'

# === TESTES OPCIONAIS ===

echo "[🧪] Testes manuais (Mapper e Reducer):"
echo "Mapper:"
docker exec namenode bash -c "head -n 100 /dados/precos-diesel-gnv-01.csv | /usr/bin/python3 /tmp/mapper.py"

echo "Reducer:"
docker exec namenode bash -c "head -n 500 /dados/precos-diesel-gnv-01.csv | /usr/bin/python3 /tmp/mapper.py | /usr/bin/python3 /tmp/reducer.py"

echo "✅ Processo concluído com sucesso!"
